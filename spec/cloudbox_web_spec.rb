require 'spec_helper'

describe "Sinatra App" do
  include VMHelpers

  it "can list VMs" do
    get "/vms"
    last_response.should be_ok
  end

  it "can list running VMs" do
    get "/running_vms"
    last_response.should be_ok
  end

  it "raises error if you try to start a VM that doesn't exist" do
    Cloudbox::VM.stub(:find).and_return(nil)
    post "/vms/uuid1-uuid1/start"
    last_response.should_not be_ok
    json = JSON.parse(last_response.body)
    json["error"].should eq("VM does not exist")
  end

  it "can start a VM" do
    Cloudbox::VM.any_instance.should_receive(:start!).and_return(true)
    Cloudbox::VM.any_instance.should_receive(:running?).and_return(false)
    post "/vms/uuid1-uuid1/start"
    last_response.should be_ok
    json = JSON.parse(last_response.body)
    json["response"].should eq("VM Started")
  end

  it "can halt a VM" do
    Cloudbox::VM.any_instance.should_receive(:halt!).and_return(true)
    Cloudbox::VM.any_instance.should_receive(:running?).and_return(true)
    post "/vms/uuid1-uuid1/halt"
    last_response.should be_ok
    json = JSON.parse(last_response.body)
    json["response"].should eq("VM Halted")
  end

  it "can delete a VM" do
    Cloudbox::VM.any_instance.should_receive(:destroy!).and_return(true)
    Cloudbox::VM.any_instance.should_receive(:running?).and_return(false)
    post "/vms/uuid1-uuid1/destroy", :uuid => "uuid1-uuid1"
    last_response.should be_ok
    json = JSON.parse(last_response.body)
    json["response"].should eq("VM Destroyed")
  end

  it "can clone a VM asyncronously" do
    Cloudbox::VM.stub(:clone_from).with("uuid1-uuid1").and_return(true)
    # Since a new thread loses all the Rspec mocks we've set up,
    # I'm stubbing out the thread here
    Thread.stub(:new).and_return(Thread.new)
    post "/vms/uuid1-uuid1/clone", :uuid => "uuid1-uuid1"
    json = JSON.parse(last_response.body)
    job_id = json["instance_id"]
    job_id.should be
  end

  it "can check the status of a provisioning VM" do
    obj = double("worker")
    obj.stub(:alive?).and_return(true)
    Cloudbox::Manager.stub(:workers).and_return({"instance123" => obj})
    Cloudbox::VM.stub(:find).and_return(Cloudbox::VM.new("uuid"))
    get "/vms/instance123"
    json = JSON.parse(last_response.body)
    json["status"].should eq("Provisioning")
    json["uuid"].should eq(nil)
  end

  it "can check the status of an error state VM" do
    obj = double("worker")
    obj.stub(:alive?).and_return(false)
    obj.stub(:value).and_return(nil)
    Cloudbox::Manager.stub(:workers).and_return({"instance123" => obj})
    Cloudbox::VM.stub(:find).and_return(Cloudbox::VM.new("uuid"))
    get "/vms/instance123"
    json = JSON.parse(last_response.body)
    json["status"].should eq("Something went wrong")
    json["uuid"].should eq(nil)
  end

  it "can check the status of a provisioned VM" do
    obj = double("worker")
    obj.stub(:alive?).and_return(false)
    obj.stub(:value).and_return("new-uuid1")
    Cloudbox::Manager.stub(:workers).and_return({"instance123" => obj})
    vm = Cloudbox::VM.new("new-uuid1")
    vm.stub(:running?).and_return(false)
    Cloudbox::VM.stub(:find).and_return(vm)
    get "/vms/instance123"
    json = JSON.parse(last_response.body)
    json["status"].should eq("VM Ready")
    json["vm"]["uuid"].should eq("new-uuid1")
  end
end
