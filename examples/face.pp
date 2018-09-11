#@PDQTest
Exec {
  path => ["/opt/puppetlabs/puppet/bin", "/usr/bin", "/bin", "/usr/local/bin"],
}

[
  "classes",
  "resources",
  "catalog",
  "filesync",
  "code_manager",
  "static_catalogs",
  "info",
].each |$face| {
  exec { "puppet lastrun ${face} > /tmp/lastrun_${face}.txt":
    creates => "/tmp/lastrun_${face}.txt",
  }
}