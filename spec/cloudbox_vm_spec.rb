require 'spec_helper'

describe Cloudbox::VM do
  include VMHelpers
  it "must be initialized with a uuid" do
    lambda { Cloudbox::VM.new }.should raise_error
    lambda { Cloudbox::VM.new("UUID") }.should_not raise_error
  end

  it "can convert a list of VM name/UUID combinations into Cloudbox::VM objects" do
    vms = Cloudbox::VM.from_list("base {uuid1-uuid1}\nbase2 {uuid2-uuid2}")
    vms.size.should eq(2)
    vms.first.class.should eq(Cloudbox::VM)
    vms.first.uuid.should eq("uuid1-uuid1")
  end

  it "can start a VM in headless mode" do
    Cloudbox::Manager.should_receive(:execute).with("VBoxManage", "startvm", "uuid1", "--type", "headless").exactly(1).times
    vm = Cloudbox::VM.new("uuid1")
    vm.start!
  end

  it "can start a VM in headless mode" do
    Cloudbox::Manager.should_receive(:execute).with("VBoxManage", "startvm", "uuid1", "--type", "headless").exactly(1).times
    vm = Cloudbox::VM.new("uuid1")
    vm.start!
  end

  it "can halt a VM" do
    Cloudbox::Manager.should_receive(:execute).with("VBoxManage", "controlvm", "uuid1", "poweroff")
    vm = Cloudbox::VM.new("uuid1")
    vm.halt!
  end

  it "can receive the VMs IP address if the VM is running" do
    vm = Cloudbox::VM.new("uuid1")
    vm.stub(:running?).and_return(false)
    vm.ip_address.should eq("")

    vm.stub(:running?).and_return(true)
    vm.ip_address.should eq("10.0.2.15")
  end

  it "supports checking equality based on uuid" do
    vm1 = Cloudbox::VM.new("uuid1")
    vm2 = Cloudbox::VM.new("uuid2")
    vm3 = Cloudbox::VM.new("uuid1")
    vm1.should_not eq(vm2)
    vm1.should eq(vm1)
    vm1.should eq(vm3)
  end

  it "returns the same hash code for equivalant VMs" do
    vm1 = Cloudbox::VM.new("uuid1")
    vm2 = Cloudbox::VM.new("uuid1")
    vm3 = Cloudbox::VM.new("uuid2")
    vm1.hash.should eq(vm2.hash)
    vm1.hash.should_not eq(vm3.hash)
  end

  it "supports standard array math" do
    vms = Cloudbox::Manager.vms
    running_vms = Cloudbox::Manager.running_vms
    (vms - running_vms).should eq([Cloudbox::VM.new("uuid2-uuid2")])

  end

  it "supports checking if a VM is running" do
    vm = Cloudbox::Manager.vms.first
    vm.running?.should be true
    vm.stub(:vm_hash).and_return({"uuid" => "uuid1", "name" => "base", "vmstate"=> "poweroff"})
    vm.running?.should be false
  end

  it "supports cloning from a given UUID" do
    return_value1 = [Cloudbox::VM.new("uuid1")]
    return_value2 = return_value1 + [Cloudbox::VM.new("newuid1")]
    Cloudbox::Manager.stub(:vms).exactly(2).times.
      and_return(return_value1, return_value2)
    vm = Cloudbox::VM.clone_from("uuid1", "new_name")
    vm.class.should eq(Cloudbox::VM)
    vm.uuid.should eq("newuid1")
  end

  it "returns information about the VM" do
    vm = Cloudbox::VM.new("uuid1-uuid1")
    vm.name.should eq("lucid32")
    vm.ostype.should eq("Ubuntu")
    vm.memory.should eq(512)
  end
end
