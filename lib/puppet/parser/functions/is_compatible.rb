require 'puppet/util/package'

Puppet::Parser::Functions.newfunction(:is_compatible, :type => :rvalue, :arity => -1, :doc => <<-EOT

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

    Check if "mod_awesome" packages in a given environment, where app is "awesome_cluster1",
    has a version >=2.0.0, <5.0.0:

      is_compatible({
        'mod_awesome' => {
          'min' => '2.0.0',
          'max' => '5.0.0',
          'fact' => 'mod_awesome_version',
          'query' => 'app="awesome_cluster1"'
        }
      })

EOT
                                     ) do |args|
  packagereqs = args[0]

  require 'puppet/util/puppetdb'
  # This is needed if the puppetdb library isn't pluginsynced to the master
  $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
  begin
    require 'puppetdb/connection'
  ensure
    $LOAD_PATH.shift
  end

  puppetdb = PuppetDB::Connection.new(Puppet::Util::Puppetdb.server, Puppet::Util::Puppetdb.port)

  Puppet.debug(packagereqs.inspect)

  !packagereqs.any? {|package,reqs|
    Puppet.debug(package.inspect)
    Puppet.debug(reqs.inspect)
    ## Construct an optional node query
    query = "environment='#{@environment || "production"}'#{(" and " + reqs['query'].to_s) if reqs['query']}"
    Puppet.debug(query)
    if reqs['fact'] and reqs['fact'].is_a? String
      query = puppetdb.parse_query query, :facts
      ops = { :extract => [:certname, :name, :value] }
      qtype = :facts
    else
      query = puppetdb.parse_query query, :facts if query and query.is_a? String
      ops = { :extract => nil }
      qtype = :resources
    end

    ## We're querying for a package unless a fact is provided
    resquery = puppetdb.parse_query "Package['#{package}']", :none if reqs['fact'].nil?
    Puppet.debug("YOUR QUERY IS: #{resquery.inspect}")

    # Construct query
    if resquery && !resquery.empty?
      q = ['and', resquery, query]
    else
      q = query
    end

    Puppet.debug("PuppetDB compatibility query generated for #{qtype.to_s}: #{query.inspect}")

    if qtype == :resources
      results = puppetdb.resources(query, resquery)
      Puppet.debug(results.inspect)
      results.values.any? {|resources|
        packagever = resources[0]['parameters']['ensure']
        Puppet.debug(packagever.inspect)
        Puppet::Util::Package.versioncmp(packagever, reqs['min']) == -1 ||
        Puppet::Util::Package.versioncmp(packagever, reqs['max']) >= 0
      }
    else
      results = puppetdb.facts(reqs['fact'], query)

      results.values.any? {|facts|
        packagever = facts[reqs['fact']]
        Puppet.debug(packagever.inspect)
        Puppet::Util::Package.versioncmp(packagever, reqs['min']) == -1 ||
        Puppet::Util::Package.versioncmp(packagever, reqs['max']) >= 0
      }
    end
  }
end
