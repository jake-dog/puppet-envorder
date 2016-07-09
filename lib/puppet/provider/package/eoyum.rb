require 'puppet/util/puppetdb'
require 'puppet/provider/package'
#require 'puppet/face'

Puppet::Type.type(:package).provide(:eoyum, :parent => :yum, :source => :yum) do
  def install
    #TODO Check to make sure that the backend actually is puppetdb
    unless !@resource[:package_settings].any? {|package,versions| !match_deps?(package, versions['min'], versions['max']) } 
      @resource.fail "External dependency [#{versions['min']} <= '#{package}' <= #{versions['max']}] not satisfied"
    end

    ## Hopefully can call super, or have to copy code out of the yum provider . . .
    super
  end

  def match_deps?(package, min, max)
    Puppet.debug("envorder: Querying PuppetDB for environment=#{@environment} and package=#{package}")

    ## Not sure if this style of the "function_*" trick works in providers . . .
    #function_query_resources(["environment='#{@environment}'", "Package['#{package}']"]).any {|node, resources|

    ## Not sure if faces work in providers, or if they're even supported . . .
    ## https://docs.puppet.com/puppet/4.5/reference/deprecated_api.html#puppet-faces-is-a-private-api
    #Puppet::Face[:query, :current].resources("environment='#{@environment}'", "Package['#{package}']").any {|node, resources|

    ## Directly invoking query_resources, using puppetdbquery
    query_resources("environment='#{@environment}'", "Package['#{package}']").any {|node, resources|
      ## Resources is an array, but there can be only one resource per node returned with the puppetdb query
      s1 = resources[0]["parameters"]["ensure"]

      Puppet.debug("envorder: Found node=#{node} with #{package}-#{s1}")

      ## rpm_compareEVR and rpm_parse_evr are inherited from the rpm provider
      rpm_compareEVR(rpm_parse_evr(s1), rpm_parse_evr(min)) && rpm_compareEVR(rpm_parse_evr(s1), rpm_parse_evr(max))
    }
  end

  ## https://github.com/dalen/puppet-puppetdbquery
  ## Using code direct from pdbquery instead of using faces for testing.
  ## Hopefully this can be switched to faces later
  def query_resources(nodequery, resquery, grouphosts)
    # This is needed if the puppetdb library isn't pluginsynced to the master
    $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
    begin
      require 'puppetdb/connection'
    ensure
      $LOAD_PATH.shift
    end

    PuppetDB::Connection.check_version

    uri = URI(Puppet::Util::Puppetdb.config.server_urls.first)
    puppetdb = PuppetDB::Connection.new(uri.host, uri.port, uri.scheme == 'https')
    parser = PuppetDB::Parser.new
    nodequery = parser.parse nodequery, :facts if nodequery and nodequery.is_a? String
    resquery = parser.parse resquery, :none if resquery and resquery.is_a? String

    # Construct query
    if resquery && !resquery.empty?
      if nodequery && !nodequery.empty?
        q = ['and', resquery, nodequery]
      else
        q = resquery
      end
    else
      fail "PuppetDB resources query error: at least one argument must be non empty; arguments were: nodequery: #{nodequery.inspect} and requery: #{resquery.inspect}"
    end

    # Fetch the results
    results = puppetdb.query(:resources, q)

    # If grouphosts is true create a nested hash with nodes and resources
    if grouphosts
      results.reduce({}) do |ret, resource|
        ret[resource['certname']] = [] unless ret.key? resource['certname']
        ret[resource['certname']] << resource
        ret
      end
    else
      results
    end
  end
end