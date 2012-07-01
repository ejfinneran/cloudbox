require 'spec_helper'

describe Cloudbox::VM do
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
    vm.start
  end

  it "can start a VM in headless mode" do
    Cloudbox::Manager.should_receive(:execute).with("VBoxManage", "startvm", "uuid1", "--type", "gui").exactly(1).times
    vm = Cloudbox::VM.new("uuid1")
    vm.start("gui")
  end

  it "can halt a VM" do
    Cloudbox::Manager.should_receive(:execute).with("VBoxManage", "controlvm", "uuid1", "poweroff")
    vm = Cloudbox::VM.new("uuid1")
    vm.halt
  end

  it "can receive the VMs IP address" do
    Cloudbox::Manager.should_receive(:execute).with("VBoxManage", "guestproperty", "get", "uuid1", "/VirtualBox/GuestInfo/Net/0/V4/IP").and_return("Value: 10.0.2.15")
    vm = Cloudbox::VM.new("uuid1")
    vm.ip_address.should eq("10.0.2.15")
  end

end
