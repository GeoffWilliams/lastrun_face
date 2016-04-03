require 'puppet'
require 'puppet/face'

Puppet::Face.define(:lastrun, '0.1.0')
  summary "Info on your last puppet run the easy way"
  copyright "Geoff Williams", 2016
  license "Apache 2"

  CACHE_DIR = "/opt/puppetlabs/puppet/cache/state/"

  action :classes do
    summary "Classes loaded during last puppet run"
    puts File.read("#{CACHE_DIR}/classes.txt")
  end

  action :resources
    summary "Resources loaded during last puppet run"
    puts File.read("#{CACHE_DIR}/resources.txt")
  end
end
  

