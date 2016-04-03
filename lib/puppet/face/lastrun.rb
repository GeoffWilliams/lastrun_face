require 'puppet'
require 'puppet/face'

Puppet::Face.define(:lastrun, '0.1.1') do
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
end
  

