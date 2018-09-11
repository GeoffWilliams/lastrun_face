require 'puppet_x'
#
# Shared functions for lastrun module
module PuppetX
  module LastRun

    # Read the last catalog as JSON
    # @return catalog as JSON or `{}` if puppet agent hasn't run yet
    def self.catalog_json
      catalog_file = File.join(
          Puppet.settings["client_datadir"],
          "catalog",
          Puppet.settings["certname"]
      ) + '.json'

      json = JSON.parse(read_file(catalog_file) || '{}')

      json
    end

    # Read a file into a string and return it
    # @return Contents of file or `false` if file not found
    def self.read_file(filename)
      if File.exists?(filename)
        data = File.read(filename)
      else
        data = false
      end
      data
    end

    # Read the list of classes last applied by puppet
    # @return Array of classes or empty array if puppet agent has not been run yet
    def self.classes
      (read_file(Puppet.settings["classfile"]) || '').split("\n")
    end

    # Read the list of resources last applied by puppet
    # @return Array of resources or empty array if puppet agent has not been run yet
    def self.resources
      (read_file(Puppet.settings["resourcefile"]) || '').split("\n")
    end

    # Report the current status of code manager (only makes sense on puppet
    # master)
    # @return "on" or "off"
    def self.code_manager_status
      classes = classes()
      if classes.include?("puppet_enterprise::master::code_manager")
        status = "on"
      else
        status = "off"
      end

      status
    end


    # Report the current status of filesync (only makes sense on puppet
    # master)
    # @return "on", "off", "indeterminate"
    def self.filesync_status
      classes = classes()
      if classes.include?("puppet_enterprise::master::file_sync_disabled")
        status = "off"
      elsif classes.include?("puppet_enterprise::master::file_sync")
        status = "on"
      else
        status = "indeterminate"
      end

      status
    end

    # Report the current status of filesync (only makes sense on puppet
    # master)
    # @return "on", "off", "indeterminate"
    def self.static_catalogs_status
      json = catalog_json()
      if json.include?("code_id")
        if json["code_id"]
          status = "on"
        else
          status = "off"
        end
      else
        status = "indeterminate"
      end

      status
    end


    # Report various information about the status of the last puppet run.
    # Key value adds:
    #   * `message` - human readable description of current puppet agent status
    #   * `alarm` - `true` if puppet agent has errors otherwise `false`
    #   * `agent_disabled` - `true` if agent has been disabled otherwise `false`
    # @return Hash
    def self.info_hash
      report_file = Puppet.settings["lastrunreport"]
      info = {}

      # intial message and alarm state.  Any error conditions encountered trip
      # the alarm
      info["message"] = ""
      info["alarm"]   = false

      # If the lockfile exists we have been disabled locally
      info["agent_disabled"] = File.exists?(Puppet.settings["agent_disabled_lockfile"])

      if info["agent_disabled"]
        info["alarm"]   = true
        info["message"] += "Puppet agent disabled by user"
      end

      if File.exists?(report_file)
        raw_data = File.readlines(report_file)

        # must skip the first line or we magically end up with a crazy puppet
        # object instead of the simple hash we asked for
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
        info["report_age"] = (DateTime.now.to_time.to_i - DateTime.parse(report["time"]).to_time.to_i).abs

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

      info
    end

  end
end