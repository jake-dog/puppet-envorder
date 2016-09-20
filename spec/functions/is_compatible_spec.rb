require 'spec_helper'
require 'puppetdb/connection'

describe 'is_compatible' do
  it { is_expected.not_to eq(nil) }
  
  context 'with implicit environment' do
    before(:each) { scope.expects(:lookupvar).with('environment').returns('production') }
    
    it 'should work with a query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]], 
                           ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['ipaddress']], ['=', 'value', '192.168.136.132']]]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]], 
                        ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'ipaddress'], ['=', 'value', '192.168.136.132']]]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1', 'query' => 'ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should work without a query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1'}}).and_return(true)
    end
    
    it 'should allow explicit environment override' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'staging']]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'staging']]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1', 'environment' => 'staging'}}).and_return(true)
    end
    
    it 'should allow empty environment' do
      if PuppetDB::Connection.respond_to? :check_version
        query = nil
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = nil
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1', 'environment' => ''}}).and_return(true)
    end
    
    it 'should allow explicit environment and node query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'staging']]]]], 
                        ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['ipaddress']], ['=', 'value', '192.168.136.132']]]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'staging']]]]], 
                        ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'ipaddress'], ['=', 'value', '192.168.136.132']]]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1', 'environment' => 'staging', 'query' => 'ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should allow multiple criteria node query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'staging']]]]], 
                        ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['ipaddress']], ['=', 'value', '192.168.136.132']]]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'staging']]]]], 
                        ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'ipaddress'], ['=', 'value', '192.168.136.132']]]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1', 'environment' => '', 'query' => 'environment=\'staging\' and ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should fail on incomaptible version when failerror=true' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "puppet.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.4.1-1.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ] 
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1'}}, true).and_raise_error(Puppet::Error)
    end
    
    it 'should find incompatible version' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ],
          "puppet.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.4.1-1.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ] 
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1'}}).and_return(false)
    end
    
    it 'should allow fact query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]], 
                        ['or', ['=', 'name', 'puppetversion']]]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'}}).and_return(true)
    end
    
    it 'should allow fact query with empty environment' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['or', ['=', 'name', 'puppetversion']]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = nil
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion', 'environment' => ''}}).and_return(true)
    end
    
    it 'should allow fact query with node query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]], 
                                ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['ipaddress']], ['=', 'value', '192.168.136.132']]]]]], 
                                ['or', ['=', 'name', 'puppetversion']]]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]], 
                        ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'ipaddress'], ['=', 'value', '192.168.136.132']]]]]]
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion', 'query' => 'ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should find incompatible fact with fact query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]], 
                        ['or', ['=', 'name', 'puppetversion']]]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' },
                { 'certname' => 'puppet.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.4.3' }]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"},
                "puppet.localdomain"=>{"puppetversion"=>"3.4.3"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'}}).and_return(false)
    end
    
    it 'should fail on incomaptible fact when failerror=true' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]], 
                        ['or', ['=', 'name', 'puppetversion']]]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'puppet.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.4.3' }]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.4.3"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'}}, true).and_raise_error(Puppet::Error)
    end
    
    it 'should allow mixed fact/resource queries' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]], 
                        ['or', ['=', 'name', 'puppetversion']]]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'puppet.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      if PuppetDB::Connection.respond_to? :check_version
        query = ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'},
                                      'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1'}}).and_return(true)
    end
    
    it 'should find incompatbile with mixed fact/resource queries' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]], 
                        ['or', ['=', 'name', 'puppetversion']]]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'puppet.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      if PuppetDB::Connection.respond_to? :check_version
        query = ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'},
                                      'tree'=> {'min' => '1.6.0-1', 'max' => '1.6.0-3'}}).and_return(false)
    end
  end
  
  context 'with no environment specified' do
    before(:each) { scope.expects(:lookupvar).with('environment').returns(nil) }

    it 'should work with a query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['ipaddress']], ['=', 'value', '192.168.136.132']]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ["in", "certname", ["extract", "certname", ["select-facts", ["and", ["=", "name", "ipaddress"], ["=", "value", "192.168.136.132"]]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1', 'query' => 'ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should work with no extra params' do
      if PuppetDB::Connection.respond_to? :check_version
        query = nil
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = nil
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1'}}).and_return(true)
    end
    
    it 'should allow explicit environment' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1', 'environment' => 'production'}}).and_return(true)
    end
    
    it 'should find incompatible version' do
      if PuppetDB::Connection.respond_to? :check_version
        query = nil
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = nil
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ],
          "puppet.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.4.1-1.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ] 
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1'}}).and_return(false)
    end
    
    it 'should allow multiple criteria node query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'staging']]]]], 
                        ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['ipaddress']], ['=', 'value', '192.168.136.132']]]]]]
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'staging']]]]], 
                        ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'ipaddress'], ['=', 'value', '192.168.136.132']]]]]]
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1', 'query' => 'environment=\'staging\' and ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should allow fact query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['or', ['=', 'name', 'puppetversion']]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = nil
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'}}).and_return(true)
    end
    
    it 'should allow fact query and node query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['ipaddress']], ['=', 'value', '192.168.136.132']]]]], 
                        ['or', ['=', 'name', 'puppetversion']]]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = ["in", "certname", ["extract", "certname", ["select-facts", ["and", ["=", "name", "ipaddress"], ["=", "value", "192.168.136.132"]]]]]
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion', 'query' => 'ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should allow explicit environment and fact query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['environment']], ['=', 'value', 'production']]]]], 
                        ['or', ['=', 'name', 'puppetversion']]]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'puppet.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]]
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion', 'environment' => 'production'}}).and_return(true)
    end
    
    it 'should find incompatible fact with fact query' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['or', ['=', 'name', 'puppetversion']]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' },
                { 'certname' => 'puppet.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.4.3' }]
      else
        query = nil
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"},
                "puppet.localdomain"=>{"puppetversion"=>"3.4.3"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'}}).and_return(false)
    end
    
    it 'should allow mixed fact/resource queries' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['or', ['=', 'name', 'puppetversion']]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = nil
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      if PuppetDB::Connection.respond_to? :check_version
        query = nil
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = nil
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'},
                                      'tree'=> {'min' => '1.5.0-3', 'max' => '1.6.0-1'}}).and_return(true)
    end
    
    it 'should find incompatbile with mixed fact/resource queries' do
      if PuppetDB::Connection.respond_to? :check_version
        query = ['or', ['=', 'name', 'puppetversion']]
        qtype = :query
        params = [ :facts, query, { :extract => [:certname, :name, :value] } ]
        rval = [{ 'certname' => 'localhost.localdomain', 'environment' => 'production', 'name' => 'puppetversion', 'value' => '3.8.7' }]
      else
        query = nil
        qtype = :facts
        params = [ "puppetversion", query ]
        rval = {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns(rval)
      if PuppetDB::Connection.respond_to? :check_version
        query = nil
        resquery = ['and', ['=', 'type', 'Package'], ['=', 'title', 'tree'], ['=', 'exported', false]]
        qtype = :query
        params = [ :resources, query && !query.empty? && ['and', resquery, query] || query ]
      else
        query = nil
        resquery = ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]]
        qtype = :resources
        params = [ query, resquery ]
      end
      PuppetDB::Connection.any_instance.expects(qtype)
        .with(*params)
        .returns({
          "localhost.localdomain" =>
            [
              {
                "title"=>"tree",
                "certname"=>"localhost.localdomain",
                "resource"=>"56933d99a4f403b05ef65a36fb3eded367f95a1c",
                "tags"=>["resource", "package", "class", "package-tree", "tree", "resource_tree", "resource_tree::resource", "default", "node"],
                "parameters"=>{"ensure"=>"1.5.3-3.el6", "provider"=>"yum", "before"=>"Resource_tree::Placeholder[package-tree]"},
                "type"=>"Package",
                "file"=>nil,
                "exported"=>false,
                "line"=>nil
              }
            ]
          })
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'},
                                      'tree'=> {'min' => '1.6.0-1', 'max' => '1.6.0-3'}}).and_return(false)
    end
  end
end
