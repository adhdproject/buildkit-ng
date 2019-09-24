module Msf::DBManager::Import::IPList
  def import_ip_list(args={}, &block)
    data = args[:data]
    wspace = args[:wspace] || workspace
    bl = validate_ips(args[:blacklist]) ? args[:blacklist].split : []

    data.each_line do |ip|
      ip.strip!
      if bl.include? ip
        next
      else
        yield(:address,ip) if block
      end
      host = find_or_create_host(:workspace => wspace, :host=> ip, :state => Msf::HostState::Alive, :task => args[:task])
    end
  end

  def import_ip_list_file(args={})
    filename = args[:filename]
    wspace = args[:wspace] || workspace

    data = ""
    ::File.open(filename, 'rb') do |f|
      data = f.read(f.stat.size)
    end
    import_ip_list(args.merge(:data => data))
  end
end
