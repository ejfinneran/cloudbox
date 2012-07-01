require 'spec_helper'

describe Cloudbox::Manager do
  it "returns a list of Cloudbox::VM objects for all vms" do

    described_class.should_receive(:execute).with("VBoxManage", "list", "vms").and_return(mock_vms_list_output)
    vms = described_class.vms
    vms.size.should eq(2)
    vms.first.class.should equal(Cloudbox::VM)
  end

  it "returns a list of Cloudbox::VM objects for all running vms" do

    described_class.should_receive(:execute).with("VBoxManage", "list", "runningvms").and_return(mock_running_vms_list_output)
    vms = described_class.running_vms
    vms.size.should eq(1)
    vms.first.class.should equal(Cloudbox::VM)
  end

  def mock_vms_list_output
    output = double("output")
    output.stub(:stdout => "box1 {uuid1-uuid1}\n box2 {uuid2-uuid2}")
    output
  end

  def mock_running_vms_list_output
    output = double("output")
    output.stub(:stdout => "box1 {uuid1-uuid1}")
    output
  end
end
