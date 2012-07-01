require 'spec_helper'

describe Cloudbox do
  it "returns a list of Cloudbox::VM objects for all vms" do

    Cloudbox.should_receive(:execute).with("VBoxManage", "list", "vms").and_return(mock_vms_list_output)
    vms = Cloudbox.vms
    vms.size.should eq(2)
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
