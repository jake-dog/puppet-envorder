require 'spec_helper'
require 'puppetdb/connection'

describe 'is_compatible' do
  it { is_expected.not_to eq(nil) }
  context 'with no environment specified' do
    #Puppet::Util::Log.level = :debug
    #Puppet::Util::Log.newdestination(:console)
    #let(:environment) { 'production' }
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
  end
end
