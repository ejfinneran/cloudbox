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
    Cloudbox::VM.any_instance.should_receive(:exists?).any_number_of_times.and_return(false)
    post "/start", :uuid => "uuid1-uuid1"
    last_response.should_not be_ok
    json = JSON.parse(last_response.body)
    json["error"].should eq("VM does not exist")
  end

  it "can start a VM" do
    Cloudbox::VM.any_instance.should_receive(:exists?).and_return(true)
    Cloudbox::VM.any_instance.should_receive(:start!).and_return(true)
    post "/start", :uuid => "uuid1-uuid1"
    last_response.should be_ok
    json = JSON.parse(last_response.body)
    json["response"].should eq("VM Started")
  end

  it "can halt a VM" do
    Cloudbox::VM.any_instance.should_receive(:exists?).and_return(true)
    Cloudbox::VM.any_instance.should_receive(:halt!).and_return(true)
    post "/halt", :uuid => "uuid1-uuid1"
    last_response.should be_ok
    json = JSON.parse(last_response.body)
    json["response"].should eq("VM Halted")
  end

  it "can delete a VM" do
    Cloudbox::VM.any_instance.should_receive(:exists?).and_return(true)
    Cloudbox::VM.any_instance.should_receive(:destroy!).and_return(true)
    post "/destroy", :uuid => "uuid1-uuid1"
    last_response.should be_ok
    json = JSON.parse(last_response.body)
    json["response"].should eq("VM Destroyed")
  end

  it "can clone a VM asyncronously" do
    Cloudbox::VM.any_instance.should_receive(:exists?).and_return(true)
    Cloudbox::VM.stub(:clone_from).with("uuid1-uuid1").and_return(true)
    # Since a new thread loses all the Rspec mocks we've set up,
    # I'm stubbing out the thread here
    Thread.stub(:new).and_return(Thread.new)
    post "/clone", :uuid => "uuid1-uuid1"
    json = JSON.parse(last_response.body)
    job_id = json["job_id"]
    job_id.should be
  end

  it "can check the status of a running clone job" do
    obj = double("worker")
    obj.stub(:alive?).and_return(true)
    Cloudbox::Web.stub(:workers).and_return({"job123" => obj})
    get "/status/job123"
    json = JSON.parse(last_response.body)
    json["status"].should eq("Running")
    json["uuid"].should eq(nil)
  end

  it "can check the status of a error state clone job" do
    obj = double("worker")
    obj.stub(:alive?).and_return(false)
    obj.stub(:value).and_return(nil)
    Cloudbox::Web.stub(:workers).and_return({"job123" => obj})
    get "/status/job123"
    json = JSON.parse(last_response.body)
    json["status"].should eq("Something went wrong")
    json["uuid"].should eq(nil)
  end

  it "can check the status of a finished clone job" do
    obj = double("worker")
    obj.stub(:alive?).and_return(false)
    obj.stub(:value).and_return("new-uuid1")
    Cloudbox::Web.stub(:workers).and_return({"job123" => obj})
    get "/status/job123"
    json = JSON.parse(last_response.body)
    json["status"].should eq("VM Ready")
    json["vm"]["uuid"].should eq("new-uuid1")
  end
end
