module Cloudbox
  class VM

    attr_reader :uuid

    def initialize(uuid)
      @uuid = uuid
    end

    class << self
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

    def start(type = "headless")
      execute("VBoxManage", "startvm", @uuid, "--type", type)
    end

    def halt
      execute("VBoxManage", "controlvm", @uuid, "poweroff")
    end

    def running?
      Cloudbox.running_vms.include?(self)
    end

    def execute(*commands)
      Cloudbox::Manager.execute(*commands)
    end

    def ip_address
      output = execute("VBoxManage", "guestproperty", "get", self.uuid, "/VirtualBox/GuestInfo/Net/0/V4/IP")
      output.match(/\d+.\d+.\d+.\d+/).to_s
    end
  end
end
