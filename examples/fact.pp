#@PDQTest
exec { "puppet facts > /tmp/lastrun_facts.txt":
  creates => "/tmp/lastrun_facts.txt",
  path => ["/opt/puppetlabs/puppet/bin", "/usr/bin", "/bin", "/usr/local/bin"],
}
