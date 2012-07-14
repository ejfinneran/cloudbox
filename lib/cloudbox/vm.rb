module Cloudbox
  class VM

    attr_reader :uuid

    def initialize(uuid)
      @uuid = uuid
    end

    class << self

      def clone_from(uuid)
        old_vms = Cloudbox::Manager.vms
        output = Cloudbox::Manager.execute("VBoxManage", "clonevm", uuid, "--register")
        new_vm = (Cloudbox::Manager.vms - old_vms).first
        new_vm
      end

      def from_list(list)
        unless list === Array
          list = list.split("\n")
        end
        vms = []
        list.each do |name|
          uuid = name.match(/{(.+)}/)[1]
          vms << Cloudbox::VM.new(uuid)
        end
        vms
      end

    end

    def ==(vm)
      return self.uuid == vm.uuid
    end

    alias_method :eql?, :==

    def <=>(vm)
      return self.uuid <=> vm.uuid
    end

    def hash
      self.uuid.hash
    end

    def exists?
      Cloudbox::Manager.vms.include?(self)
    end

    def running?
      Cloudbox::Manager.running_vms.include?(self)
    end

    def ip_address
      return "" unless self.running?
      output = execute("VBoxManage", "guestproperty", "get", self.uuid, "/VirtualBox/GuestInfo/Net/0/V4/IP")
      output.match(/\d+.\d+.\d+.\d+/).to_s
    end

    def start!(type = "headless")
      execute("VBoxManage", "startvm", @uuid, "--type", type)
    end

    def halt!
      execute("VBoxManage", "controlvm", @uuid, "poweroff")
    end

    def clone!
      self.class.clone_from(self.uuid)
    end

    def destroy!
      execute("vboxmanage", "unregistervm", @uuid, "--delete")
    end

    def execute(*commands)
      Cloudbox::Manager.execute(*commands)
    end

  end
end
