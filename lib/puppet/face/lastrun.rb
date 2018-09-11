require 'puppet'
require 'puppet/face'
require 'json'
require 'yaml'
require 'date'
require 'puppet_x/lastrun'

# Information about the last puppet agent run
Puppet::Face.define(:lastrun, '0.5.0') do
  summary "Info on your last puppet run the easy way"
  copyright "Geoff Williams", 2017
  license "Apache 2"

  MISSING_MSG = "Not available (run puppet first?)"

  action :classes do
    summary "Classes loaded during last puppet run"

    when_invoked do |options|
      PuppetX::LastRun.classes().each do |x|
        puts x
      end.empty? && begin
        puts MISSING_MSG
      end
    end
  end

  action :resources do
    summary "Resources loaded during last puppet run"

    when_invoked do |options|
      PuppetX::LastRun.resources().each do |x|
        puts x
      end.empty? && begin
        puts MISSING_MSG
      end
    end
  end


  action :catalog do
    summary "Last applied catalog"

    when_invoked do |options|
      json = PuppetX::LastRun.catalog_json
      json_pp = json.empty? ? MISSING_MSG : JSON.pretty_generate(json)

      puts json_pp

    end
  end

  action :filesync do
    summary "Was filesync active on last puppet run?"

    when_invoked do |options|
      puts PuppetX::LastRun.filesync_status
    end
  end

  action :code_manager do
    summary "Is code manager active (masters only)?"

    when_invoked do |options|
      puts PuppetX::LastRun.code_manager_status
    end
  end

  action :static_catalogs do
    summary "Are static catalogs being used?"

    when_invoked do |options|
      puts PuppetX::LastRun.static_catalogs_status
    end
  end


  action :info do
    summary "Info about the last puppet run (how long ago, status, etc"

    when_invoked do |options|
      JSON.pretty_generate(PuppetX::LastRun.info_hash)
    end
  end


end
