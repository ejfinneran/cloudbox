# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'cloudbox'
require 'simplecov'
SimpleCov.start

require 'sinatra'
require 'rack/test'

set :run, false

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Rack::Test::Methods
end

def app
  Cloudbox::Web
end

RSpec.configure do |config|
  config.before(:each) do
    Cloudbox::Manager.stub(:vms).and_return(Cloudbox::VM.from_list(mock_vms_list_output))
    Cloudbox::Manager.stub(:running_vms).and_return(Cloudbox::VM.from_list(mock_running_vms_list_output))
    Cloudbox::VM.any_instance.stub(:vm_hash).and_return(
      {"name" => "lucid32",
       "ostype" => "Ubuntu",
       "memory" => 512,
       "UUID" => "uuid1-uuid1",
       "macaddress1" => "08002726EC2D"}
    )
    Cloudbox::Manager.should_receive(:execute).with("VBoxManage", "guestproperty", "get", kind_of(String), "/VirtualBox/GuestInfo/Net/0/V4/IP").any_number_of_times.and_return("Value: 10.0.2.15")
    Cloudbox::Manager.should_receive(:execute).with("VBoxManage", "clonevm", kind_of(String), "--register").any_number_of_times.and_return("")
  end
end

module VMHelpers
  def mock_vms_list_output
    "box1 {uuid1-uuid1}\n box2 {uuid2-uuid2}"
  end

  def mock_running_vms_list_output
    "box1 {uuid1-uuid1}"
  end
end
