# -*- coding: binary -*-

module Msf::Post::Common

  def rhost
    case session.type
    when 'meterpreter'
      session.sock.peerhost
    when 'shell'
      session.session_host
    end
  end

  def rport
    case session.type
    when 'meterpreter'
      session.sock.peerport
    when 'shell'
      session.session_port
    end
  end

  def peer
    "#{rhost}:#{rport}"
  end

  #
  # Checks if the remote system has a process with ID +pid+
  #
  def has_pid?(pid)
    pid_list = []
    case client.type
    when /meterpreter/
      pid_list = client.sys.process.processes.collect {|e| e['pid']}
    when /shell/
      if client.platform =~ /win/
        o = cmd_exec('tasklist /FO LIST')
        pid_list = o.scan(/^PID:\s+(\d+)/).flatten
      else
        o = cmd_exec('ps ax')
        pid_list = o.scan(/^\s*(\d+)/).flatten
      end

      pid_list = pid_list.collect {|e| e.to_i}
    end

    pid_list.include?(pid)
  end

  #
  # Executes +cmd+ on the remote system
  #
  # On Windows meterpreter, this will go through CreateProcess as the
  # "commandLine" parameter. This means it will follow the same rules as
  # Windows' path disambiguation. For example, if you were to call this method
  # thusly:
  #
  #     cmd_exec("c:\\program files\\sub dir\\program name")
  #
  # Windows would look for these executables, in this order, passing the rest
  # of the line as arguments:
  #
  #     c:\program.exe
  #     c:\program files\sub.exe
  #     c:\program files\sub dir\program.exe
  #     c:\program files\sub dir\program name.exe
  #
  # On POSIX meterpreter, if +args+ is set or if +cmd+ contains shell
  # metacharacters, the server will run the whole thing in /bin/sh. Otherwise,
  # (cmd is a single path and there are no arguments), it will execve the given
  # executable.
  #
  # On Java, it is passed through Runtime.getRuntime().exec(String) and PHP
  # uses proc_open() both of which have similar semantics to POSIX.
  #
  # On shell sessions, this passes +cmd+ directly the session's
  # +shell_command_token+ method.
  #
  # Returns a (possibly multi-line) String.
  #
  def cmd_exec(cmd, args=nil, time_out=15)
    case session.type
    when /meterpreter/
      #
      # The meterpreter API requires arguments to come seperately from the
      # executable path. This has no effect on Windows where the two are just
      # blithely concatenated and passed to CreateProcess or its brethren. On
      # POSIX, this allows the server to execve just the executable when a
      # shell is not needed. Determining when a shell is not needed is not
      # always easy, so it assumes anything with arguments needs to go through
      # /bin/sh.
      #
      # This problem was originally solved by using Shellwords.shellwords but
      # unfortunately, it is retarded. When a backslash occurs inside double
      # quotes (as is often the case with Windows commands) it inexplicably
      # removes them. So. Shellwords is out.
      #
      # By setting +args+ to an empty string, we can get POSIX to send it
      # through /bin/sh, solving all the pesky parsing troubles, without
      # affecting Windows.
      #
      if args.nil? and cmd =~ /[^a-zA-Z0-9\/._-]/
        args = ""
      end

      session.response_timeout = time_out
      process = session.sys.process.execute(cmd, args, {'Hidden' => true, 'Channelized' => true})
      o = ""
      while (d = process.channel.read)
        break if d == ""
        o << d
      end
      o.chomp! if o

      begin
        process.channel.close
      rescue IOError => e
        # Channel was already closed, but we got the cmd output, so let's soldier on.
      end

      process.close
    when /shell/
      o = session.shell_command_token("#{cmd} #{args}", time_out)
      o.chomp! if o
    end
    return "" if o.nil?
    return o
  end

  def cmd_exec_get_pid(cmd, args=nil, time_out=15)
    case session.type
      when /meterpreter/
        if args.nil? and cmd =~ /[^a-zA-Z0-9\/._-]/
          args = ""
        end
        session.response_timeout = time_out
        process = session.sys.process.execute(cmd, args, {'Hidden' => true, 'Channelized' => true})
        process.channel.close
        pid = process.pid
        process.close
        pid
      else
        print_error "cmd_exec_get_pid is incompatible with non-meterpreter sessions"
    end
  end

  #
  # Reports to the database that the host is a virtual machine and reports
  # the type of virtual machine it is (e.g VirtualBox, VMware, Xen)
  #
  def report_vm(vm)
    return unless session
    return unless vm
    vm_normal = vm.to_s.strip
    return if vm_normal.empty?
    vm_data = {
      :host => session.target_host,
      :virtual_host => vm_normal
    }
    report_host(vm_data)
  end

  #
  # Returns the value of the environment variable +env+
  #
  def get_env(env)
    case session.type
    when /meterpreter/
      return session.sys.config.getenv(env)
    when /shell/
      if session.platform =~ /win/
        if env[0,1] == '%'
          unless env[-1,1] == '%'
            env << '%'
          end
        else
          env = "%#{env}%"
        end

        return cmd_exec("echo #{env}")
      else
        unless env[0,1] == '$'
          env = "$#{env}"
        end

        return cmd_exec("echo \"#{env}\"")
      end
    end

    nil
  end

  #
  # Returns a hash of environment variables +envs+
  #
  def get_envs(*envs)
    case session.type
    when /meterpreter/
      return session.sys.config.getenvs(*envs)
    when /shell/
      result = {}
      envs.each do |env|
        res = get_env(env)
        result[env] = res unless res.blank?
      end

      return result
    end

    nil
  end

end

