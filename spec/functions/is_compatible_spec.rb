require 'spec_helper'
require 'puppetdb/connection'

describe 'is_compatible' do
  it { is_expected.not_to eq(nil) }
  
  context 'with implicit environment' do
    before(:each) { scope.expects(:lookupvar).with('environment').returns('production') }
    
    it 'should work with a query' do
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(['and', ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]], 
                      ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'ipaddress'], ['=', 'value', '192.168.136.132']]]]]],
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]],
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'staging']]]]],
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(nil,
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(['and', ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'staging']]]]], 
                      ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'ipaddress'], ['=', 'value', '192.168.136.132']]]]]],
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
    
    it 'should find incompatible version' do
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]],
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
      PuppetDB::Connection.any_instance.expects(:facts)
        .with("puppetversion",
              ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]])
        .returns(
            {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
          )
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'}}).and_return(true)
    end
    
    it 'should allow fact query with empty environment' do
      PuppetDB::Connection.any_instance.expects(:facts)
        .with("puppetversion",
              nil)
        .returns(
            {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
          )
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion', 'environment' => ''}}).and_return(true)
    end
    
    it 'should allow fact query with node query' do
      PuppetDB::Connection.any_instance.expects(:facts)
        .with("puppetversion",
              ['and', ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]], 
                      ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'ipaddress'], ['=', 'value', '192.168.136.132']]]]]])
        .returns(
            {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
          )
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion', 'query' => 'ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should find incompatible fact with fact query' do
      PuppetDB::Connection.any_instance.expects(:facts)
        .with("puppetversion",
              ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]])
        .returns(
            {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"},
             "puppet.localdomain"=>{"puppetversion"=>"3.4.3"}}
          )
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'}}).and_return(false)
    end
  end
  
  context 'with no environment specified' do
    it 'should work with a query' do
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(["in", "certname", ["extract", "certname", ["select-facts", ["and", ["=", "name", "ipaddress"], ["=", "value", "192.168.136.132"]]]]],
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(nil,
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
      PuppetDB::Connection.any_instance.expects(:resources)
        .with(['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]],
              ["and", ["=", "exported", false], ["=", "type", "Package"], ["=", "title", "tree"]])
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
    
    it 'should allow fact query' do
      PuppetDB::Connection.any_instance.expects(:facts)
        .with("puppetversion",
              nil)
        .returns(
            {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
          )
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion'}}).and_return(true)
    end
    
    it 'should allow fact query and node query' do
      PuppetDB::Connection.any_instance.expects(:facts)
        .with("puppetversion",
              ["in", "certname", ["extract", "certname", ["select-facts", ["and", ["=", "name", "ipaddress"], ["=", "value", "192.168.136.132"]]]]])
        .returns(
            {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
          )
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion', 'query' => 'ipaddress=\'192.168.136.132\''}}).and_return(true)
    end
    
    it 'should allow explicit environment and fact query' do
      PuppetDB::Connection.any_instance.expects(:facts)
        .with("puppetversion",
              ['in', 'certname', ['extract', 'certname', ['select-facts', ['and', ['=', 'name', 'environment'], ['=', 'value', 'production']]]]])
        .returns(
            {"localhost.localdomain"=>{"puppetversion"=>"3.8.7"}}
          )
      is_expected.to run.with_params({'puppet'=> {'min' => '3.6.0', 'max' => '4.0.0', 'fact' => 'puppetversion', 'environment' => 'production'}}).and_return(true)
    end
  end
end
