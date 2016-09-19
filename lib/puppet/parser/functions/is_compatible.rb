require 'puppet/util/package'

Puppet::Parser::Functions.newfunction(:is_compatible, :type => :rvalue, :arity => -2, :doc => <<-EOT

  Accepts one argument: a hash keyed by package names, with each value being a hash with a
  minimum and/or maximum acceptable package version, with optional resource query parameters
  and optional fact name (by default the ensure property of the Package[name] is compared)

  Examples:

    Verify that all 'httpd' packages in given environment are version >=2.0.0, <5.0.0:

      is_compatible({
        'httpd' => {
          'min' => '2.0.0',
          'max' => '5.0.0'
        }
      })

    Check if "mod_awesome" in a given environment has a version >=2.0.0, <5.0.0 with a
    custom mod_awesome_version fact:

      is_compatible({
        'mod_awesome' => {
          'min' => '2.0.0',
          'max' => '5.0.0',
          'fact' => 'mod_awesome_version'
        }
      })

    Check if "mod_awesome" in a given environment, where app is "awesome_cluster1", has a
    version >=2.0.0, <5.0.0 with a custom mod_awesome_version fact:

      is_compatible({
        'mod_awesome' => {
          'min' => '2.0.0',
          'max' => '5.0.0',
          'fact' => 'mod_awesome_version',
          'query' => 'app="awesome_cluster1"'
        }
      })

    Check if 'httpd' packages in a given environment, where app is "awesome_cluster1",
    has a version >=2.0.0, <5.0.0:

      is_compatible({
        'httpd' => {
          'min' => '2.0.0',
          'max' => '5.0.0',
          'query' => 'app="httpd_cluster1"'
        }
      })

EOT
                                     ) do |args|
  packagereqs, failerrors = args
  failerrors = !!failerrors
  environment = lookupvar('environment')

  require 'puppet/util/puppetdb'
  # This is needed if the puppetdb library isn't pluginsynced to the master
  $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
  begin
    require 'puppetdb/connection'
  ensure
    $LOAD_PATH.shift
  end

  ## compatbility with pdbquery 2.x
  if PuppetDB::Connection.respond_to? :check_version
    PuppetDB::Connection.check_version

    uri = URI(Puppet::Util::Puppetdb.config.server_urls.first)
    puppetdb = PuppetDB::Connection.new(uri.host, uri.port, uri.scheme == 'https')
    parser = PuppetDB::Parser.new
  else
    puppetdb = PuppetDB::Connection.new(Puppet::Util::Puppetdb.server, Puppet::Util::Puppetdb.port)
  end

  !packagereqs.any? {|package,reqs|
    ## Construct an optional node query, including an environment if found
    query = if reqs['environment'] && !reqs['environment'].empty? && reqs['environment'].is_a?(String)
      ["environment='#{reqs['environment']}'"]
    elsif reqs['environment'] == ''
      debug("envorder: Empty environment specified.  Reverting to global check")
      []
    elsif environment && !environment.empty? && environment.is_a?(String)
      ["environment='#{environment}'"]
    else
      debug("envorder: No environment variable, or no environment specified.  Reverting to global check")
      []
    end
    query = query + [reqs['query']] if reqs['query'] && reqs['query'].is_a?(String)
    query = query.join(" and ")

    ## compatbility with pdbquery 2.x
    if defined? parser
      if reqs['fact'] and reqs['fact'].is_a? String
        q = parser.facts_query query, reqs['fact']
        Puppet.debug("envorder: compatibility query generated for facts: #{q.inspect}")
        results = puppetdb.query(:facts, q, { :extract => [:certname, :name, :value] })
        results = parser.facts_hash(results)
        results = results.values.map {|facts| facts[reqs['fact']] }
      else
        resquery = parser.parse "Package['#{package}']", :none
        query = parser.parse query, :facts if query and query.is_a? String
        q = query && !query.empty? && ['and', resquery, query] || query
        Puppet.debug("envorder: compatibility query generated for resources: #{q.inspect}")
        results = puppetdb.query(:resources, q)
        results = results.values.map {|resources| resources[0]['parameters']['ensure'] }
      end
    else
      query = puppetdb.parse_query query, :facts if query and query.is_a?(String)
      if reqs['fact'] and reqs['fact'].is_a? String
        Puppet.debug("envorder: compatibility query generated for facts: #{query.inspect}")
        results = puppetdb.facts(reqs['fact'], query)
        results = results.values.map {|facts| facts[reqs['fact']] }
      else
        resquery = puppetdb.parse_query "Package['#{package}']", :none
        Puppet.debug("envorder: compatibility query generated for resources: #{["and", [query,resquery]].inspect}")
        results = puppetdb.resources(query, resquery)
        results = results.values.map {|resources| resources[0]['parameters']['ensure'] }
      end
    end

    results.any? {|packagever|
      Puppet::Util::Package.versioncmp(packagever, reqs['min']) == -1 ||
      Puppet::Util::Package.versioncmp(packagever, reqs['max']) >= 0
    }
  } || (failerrors && fail("envorder: incompatible version detected"))
end
