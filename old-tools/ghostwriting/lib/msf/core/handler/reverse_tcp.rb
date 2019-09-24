# -*- coding: binary -*-
require 'rex/socket'
require 'thread'

module Msf
module Handler

###
#
# This module implements the reverse TCP handler.  This means
# that it listens on a port waiting for a connection until
# either one is established or it is told to abort.
#
# This handler depends on having a local host and port to
# listen on.
#
###
module ReverseTcp

  include Msf::Handler

  #
  # Returns the string representation of the handler type, in this case
  # 'reverse_tcp'.
  #
  def self.handler_type
    return "reverse_tcp"
  end

  #
  # Returns the connection-described general handler type, in this case
  # 'reverse'.
  #
  def self.general_handler_type
    "reverse"
  end

  #
  # Initializes the reverse TCP handler and ads the options that are required
  # for all reverse TCP payloads, like local host and local port.
  #
  def initialize(info = {})
    super

    register_options(
      [
        Opt::LHOST,
        Opt::LPORT(4444)
      ], Msf::Handler::ReverseTcp)

    # XXX: Not supported by all modules
    register_advanced_options(
      [
        OptInt.new('ReverseConnectRetries', [ true, 'The number of connection attempts to try before exiting the process', 5 ]),
        OptAddress.new('ReverseListenerBindAddress', [ false, 'The specific IP address to bind to on the local system']),
        OptInt.new('ReverseListenerBindPort', [ false, 'The port to bind to on the local system if different from LPORT' ]),
        OptString.new('ReverseListenerComm', [ false, 'The specific communication channel to use for this listener']),
        OptBool.new('ReverseAllowProxy', [ true, 'Allow reverse tcp even with Proxies specified. Connect back will NOT go through proxy but directly to LHOST', false]),
        OptBool.new('ReverseListenerThreaded', [ true, 'Handle every connection in a new thread (experimental)', false])
      ], Msf::Handler::ReverseTcp)

    self.handler_queue = ::Queue.new
    self.conn_threads = []
  end

  #
  # Starts the listener but does not actually attempt
  # to accept a connection.  Throws socket exceptions
  # if it fails to start the listener.
  #
  def setup_handler
    if datastore['Proxies'] and not datastore['ReverseAllowProxy']
      raise RuntimeError, "TCP connect-back payloads cannot be used with Proxies. Use 'set ReverseAllowProxy true' to override this behaviour."
    end

    ex = false

    comm  = datastore['ReverseListenerComm']
    if comm.to_s == "local"
      comm = ::Rex::Socket::Comm::Local
    else
      comm = nil
    end

    local_port = bind_port
    addrs = bind_address

    addrs.each { |ip|
      begin

        self.listener_sock = Rex::Socket::TcpServer.create(
          'LocalHost' => ip,
          'LocalPort' => local_port,
          'Comm'      => comm,
          'Context'   =>
            {
              'Msf'        => framework,
              'MsfPayload' => self,
              'MsfExploit' => assoc_exploit
            })

        ex = false

        comm_used = comm || Rex::Socket::SwitchBoard.best_comm( ip )
        comm_used = Rex::Socket::Comm::Local if comm_used == nil

        if( comm_used.respond_to?( :type ) and comm_used.respond_to?( :sid ) )
          via = "via the #{comm_used.type} on session #{comm_used.sid}"
        else
          via = ""
        end

        print_status("Started reverse handler on #{ip}:#{local_port} #{via}")
        break
      rescue
        ex = $!
        print_error("Handler failed to bind to #{ip}:#{local_port}")
      end
    }
    raise ex if (ex)
  end

  #
  # Closes the listener socket if one was created.
  #
  def cleanup_handler
    stop_handler

    # Kill any remaining handle_connection threads that might
    # be hanging around
    conn_threads.each { |thr|
      thr.kill rescue nil
    }
  end

  #
  # Starts monitoring for an inbound connection.
  #
  def start_handler
    local_port = bind_port
    self.listener_thread = framework.threads.spawn("ReverseTcpHandlerListener-#{local_port}", false) {
      client = nil

      begin
        # Accept a client connection
        begin
          client = self.listener_sock.accept
        rescue
          wlog("Exception raised during listener accept: #{$!}\n\n#{$@.join("\n")}")
          break
        end

        # Increment the has connection counter
        self.pending_connections += 1

        self.handler_queue.push( client )
      end while true
    }

    self.handler_thread = framework.threads.spawn("ReverseTcpHandlerWorker-#{local_port}", false) {
      while true
        client = self.handler_queue.pop
        begin
          if datastore['ReverseListenerThreaded']
            self.conn_threads << framework.threads.spawn("ReverseTcpHandlerSession-#{local_port}-#{client.peerhost}", false, client) { | client_copy|
              handle_connection(wrap_aes_socket(client_copy))
            }
          else
            handle_connection(wrap_aes_socket(client))
          end
        rescue ::Exception
          elog("Exception raised from handle_connection: #{$!.class}: #{$!}\n\n#{$@.join("\n")}")
        end
      end
    }

  end

  def wrap_aes_socket(sock)
    if datastore["PAYLOAD"] !~ /java\// or (datastore["AESPassword"] || "") == ""
      return sock
    end

    socks = Rex::Socket::tcp_socket_pair()
    socks[0].extend(Rex::Socket::Tcp)
    socks[1].extend(Rex::Socket::Tcp)

    m = OpenSSL::Digest.new('md5')
    m.reset
    key = m.digest(datastore["AESPassword"] || "")

    Rex::ThreadFactory.spawn('AESEncryption', false) {
      c1 = OpenSSL::Cipher.new('aes-128-cfb8')
      c1.encrypt
      c1.key=key
      sock.put([0].pack('N'))
      sock.put(c1.iv=c1.random_iv)
      buf1 = socks[0].read(4096)
      while buf1 and buf1 != ""
        sock.put(c1.update(buf1))
        buf1 = socks[0].read(4096)
      end
      sock.close()
    }
    Rex::ThreadFactory.spawn('AESEncryption', false) {
      c2 = OpenSSL::Cipher.new('aes-128-cfb8')
      c2.decrypt
      c2.key=key
      iv=""
      while iv.length < 16
        iv << sock.read(16-iv.length)
      end
      c2.iv = iv
      buf2 = sock.read(4096)
      while buf2 and buf2 != ""
        socks[0].put(c2.update(buf2))
        buf2 = sock.read(4096)
      end
      socks[0].close()
    }
    return socks[1]
  end

  #
  # Stops monitoring for an inbound connection.
  #
  def stop_handler
    # Terminate the listener thread
    if (self.listener_thread and self.listener_thread.alive? == true)
      self.listener_thread.kill
      self.listener_thread = nil
    end

    # Terminate the handler thread
    if (self.handler_thread and self.handler_thread.alive? == true)
      self.handler_thread.kill
      self.handler_thread = nil
    end

    if (self.listener_sock)
      self.listener_sock.close
      self.listener_sock = nil
    end
  end

protected

  def bind_port
    port = datastore['ReverseListenerBindPort'].to_i
    port > 0 ? port : datastore['LPORT'].to_i
  end

  def bind_address
    # Switch to IPv6 ANY address if the LHOST is also IPv6
    addr = Rex::Socket.resolv_nbo(datastore['LHOST'])
    # First attempt to bind LHOST. If that fails, the user probably has
    # something else listening on that interface. Try again with ANY_ADDR.
    any = (addr.length == 4) ? "0.0.0.0" : "::0"

    addrs = [ Rex::Socket.addr_ntoa(addr), any  ]

    if not datastore['ReverseListenerBindAddress'].to_s.empty?
      # Only try to bind to this specific interface
      addrs = [ datastore['ReverseListenerBindAddress'] ]

      # Pick the right "any" address if either wildcard is used
      addrs[0] = any if (addrs[0] == "0.0.0.0" or addrs == "::0")
    end

    addrs
  end

  attr_accessor :listener_sock # :nodoc:
  attr_accessor :listener_thread # :nodoc:
  attr_accessor :handler_thread # :nodoc:
  attr_accessor :handler_queue # :nodoc:
  attr_accessor :conn_threads # :nodoc:
end

end
end
