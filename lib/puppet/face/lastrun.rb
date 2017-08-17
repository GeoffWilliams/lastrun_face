require 'puppet'
require 'puppet/face'
require 'json'
require 'yaml'
require 'date'

Puppet::Face.define(:lastrun, '0.3.0') do
  summary "Info on your last puppet run the easy way"
  copyright "Geoff Williams", 2017
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


  action :catalog do
    summary "Last applied catalog"

    when_invoked do |options|
      catalog_file = File.join(
        %x[puppet config print client_datadir].strip, 
        "catalog", 
        %x[puppet config print certname].strip
      ) + '.json'

      puts JSON.pretty_generate(JSON.parse(File.read(catalog_file)))
    end
  end

  action :filesync do
    summary "Was filesync active on last puppet run?"

    when_invoked do |options|
      classes = File.read(%x[puppet config print classfile].strip)
      # reversed order to avoid false positive partial match on
      # puppet_enterprise::master::file_sync
      if classes.include?("puppet_enterprise::master::file_sync_disabled")
        status = "off"
      elsif classes.include?("puppet_enterprise::master::file_sync")
        status = "on"
      else
        status = "indeterminate"
      end
      puts status
    end
  end

  action :code_manager do
    summary "Is code manager active (masters only)?"

    when_invoked do |options|
      classes = File.read(%x[puppet config print classfile].strip)
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


  action :info do
    summary "Info about the last puppet run (how long ago, status, etc"

    when_invoked do |options|
      report_file = %x[puppet agent --configprint lastrunreport].strip
      info = {}

      # intial message and alarm state.  Any error conditions encountered trip
      # the alarm
      info["message"] = ""
      info["alarm"]   = false

      # If the lockfile exists we have been disabled locally
      info["agent_disabled"] = File.exists?(%x[puppet agent --configprint agent_disabled_lockfile].strip)

      if info["agent_disabled"]
        info["alarm"]   = true
        info["message"] += "Puppet agent disabled by user"
      end

      if File.exists?(report_file)
        # must skip the first line or we magically end up with a crazy puppet
        # object instead of the simple hash we asked for
        first_line = true
        raw_data = File.readlines(report_file)
        raw_data.shift
        report = YAML.load(raw_data.join)

        # Collect the main info report
        # YAML already parsed a date object for us when decoding...
        info["time"]              = report["time"]
        info["status"]            = report["status"]
        info["noop"]              = report["noop"]
        info["environment"]       = report["environment"]
        info["corrective_change"] = report["corrective_change"]

        # good: 'changed', 'unchanged'; bad: everything else
        if info["status"] != 'changed' and info["status"] != 'unchanged'
          info["alarm"]   = true
          if info["message"]  != ""
            info["message"]   += "; "
          end
          info["message"] += "status indicates error, check report"
        end

        # figure out how long ago the puppet run was
        info["report_age"] = (DateTime.now.to_time.to_i - report["time"].to_time.to_i).abs

        # 1 hour
        max_age = 60*60
        if info["report_age"] > max_age
          info["alarm"]   = true
          if info["message"]  != ""
            info["message"]   += "; "
          end
          info["message"] += "puppet report older then #{max_age} seconds, check running?"
        end
      else
        info["alarm"]              = true
        info["time"]               = false
        info["status"]             = "error"
        info["noop"]               = false
        info["environment"]        = false
        info["corrective_change"]  = false
        info["report_age"]         = false
        info["message"]            = "report file not available at #{report_file}, check running?"
      end

      puts JSON.pretty_generate(info)
    end
  end


end
