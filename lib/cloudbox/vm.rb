module Cloudbox
  class VM
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

    def start(type = "headless")
      execute("VBoxManage", "controlvm", @uuid, "startvm")
    end

    def halt
      execute("VBoxManage", "controlvm", @uuid, "poweroff")
    end

    def running?
      Cloudbox.running_vms.include?(self)
    end

  end
end
