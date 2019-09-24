require 'rex/parser/retina_xml'

module Msf::DBManager::Import::Retina
  # Process Retina XML
  def import_retina_xml(args={}, &block)
    data = args[:data]
    wspace = args[:wspace] || workspace
    bl = validate_ips(args[:blacklist]) ? args[:blacklist].split : []
    msg =  "Warning: The Retina XML format does not associate vulnerabilities with the\n"
    msg << "specific service on which they were found.\n"
    msg << "This makes it impossible to correlate exploits to discovered vulnerabilities\n"
    msg << "in a reliable fashion."

    yield(:warning,msg) if block

    parser = Rex::Parser::RetinaXMLStreamParser.new
    parser.on_found_host = Proc.new do |host|
      hobj = nil
      data = {
        :workspace => wspace,
        :task      => args[:task]
      }
      addr = host['address']
      next if not addr

      next if bl.include? addr
      data[:host] = addr

      if host['mac']
        data[:mac] = host['mac']
      end

      data[:state] = Msf::HostState::Alive

      if host['hostname']
        data[:name] = host['hostname']
      end

      if host['netbios']
        data[:name] = host['netbios']
      end

      yield(:address, data[:host]) if block

      # Import Host
      hobj = report_host(data)
      report_import_note(wspace, hobj)

      # Import OS fingerprint
      if host["os"]
        note = {
            :workspace => wspace,
            :host      => addr,
            :type      => 'host.os.retina_fingerprint',
            :task      => args[:task],
            :data      => {
                :os => host["os"]
            }
        }
        report_note(note)
      end

      # Import vulnerabilities
      host['vulns'].each do |vuln|
        refs = vuln['refs'].map{|v| v.join("-")}
        refs << "RETINA-#{vuln['rthid']}" if vuln['rthid']

        vuln_info = {
            :workspace => wspace,
            :host      => addr,
            :name      => vuln['name'],
            :info      => vuln['description'],
            :refs      => refs,
            :task      => args[:task]
        }

        report_vuln(vuln_info)
      end
    end

    REXML::Document.parse_stream(data, parser)
  end

  # Process a Retina XML file
  def import_retina_xml_file(args={})
    filename = args[:filename]
    wspace = args[:wspace] || workspace

    data = ""
    ::File.open(filename, 'rb') do |f|
      data = f.read(f.stat.size)
    end
    import_retina_xml(args.merge(:data => data))
  end
end
