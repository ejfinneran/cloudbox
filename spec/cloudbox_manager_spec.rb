require 'spec_helper'

describe Cloudbox::Manager do
  include VMHelpers
  it "returns a list of Cloudbox::VM objects for all vms" do

    vms = described_class.vms
    vms.size.should eq(2)
    vms.first.class.should equal(Cloudbox::VM)
  end

  it "returns a list of Cloudbox::VM objects for all running vms" do

    vms = described_class.running_vms
    vms.size.should eq(1)
    vms.first.class.should equal(Cloudbox::VM)
  end

end
