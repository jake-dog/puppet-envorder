# Minimal mock class for PuppetDB config
module Puppet::Util::Puppetdb
  def self.server
    "http://puppetdb.puppetexplorer.io"
  end

  def self.port
    443
  end
end
