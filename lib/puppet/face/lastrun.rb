require 'puppet'
require 'puppet/face'
require 'json'

Puppet::Face.define(:lastrun, '0.2.0') do
  summary "Info on your last puppet run the easy way"
  copyright "Geoff Williams", 2016
  license "Apache 2"

  action :classes do
    summary "Classes loaded during last puppet run"

    when_invoked do |options|
      puts File.read(%x[puppet config print classfile].strip)
    end
  end

  action :resources do
    summary "Resources loaded during last puppet run"

    when_invoked do |options|
      puts File.read(%x[puppet config print resourcefile].strip)
    end
  end

  action :filesync do
    summary "Was filesync active on last puppet run?"

    when_invoked do |options|
      classes = %x[puppet config print classfile].strip
      if classes.include?("puppet_enterprise::master::file_sync")
        status = "on"
      elsif classes.include?("puppet_enterprise::master::file_sync_disabled")
        status = "off"
      else
        status = "indeterminate"
      end
      puts status
    end
  end

  action :code_manager do
    summary "Is code manager active (masters only)?"

    when_invoked do |options| 
      classes = %x[puppet config print classfile].strip
      if classes.include?("puppet_enterprise::master::code_manager")
        status = "on"
      else
        status = "off"
      end
      puts status
    end
  end

  action :static_catalogs do
    summary "Are static catalogs being used?"
    
    when_invoked do |options|
      client_datadir = %x[puppet agent --configprint client_datadir].strip
      fqdn = %x[facter fqdn].strip
      sep = File::SEPARATOR
      catalog_file = "#{client_datadir}#{sep}catalog#{sep}#{fqdn}.json"
      parsed = JSON.parse(File.read(catalog_file))
      if parsed.include?("code_id")
        if parsed["code_id"]
          status = "on"
        else
        status = "off"
        end
      else
        status = "indeterminate"
      end
      puts status
    end
  end

end
  

