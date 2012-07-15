module Cloudbox
  class VM

    attr_reader :uuid

    def initialize(uuid)
      @uuid = uuid
    end

    class << self

      def clone_from(uuid, boot = false)
        old_vms = Cloudbox::Manager.vms
        begin
          output = Cloudbox::Manager.execute("VBoxManage", "clonevm", uuid, "--register")
          new_vm = (Cloudbox::Manager.vms - old_vms).first
          new_vm.start! if boot
          new_vm
        rescue Mixlib::ShellOut::ShellCommandFailed
          # if we see that the Clone job was cancelled, just return false and
          # move along. If not, something else went wrong and we should re-raise
          if $!.message.include?("VERR_CANCELLED")
            false
          else
            raise $!
          end
        end
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

    def method_missing(method, *args)
      if vm_hash[method.to_s]
        return vm_hash[method.to_s]
      else
        super
      end
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

    private

    def execute(*commands)
      Cloudbox::Manager.execute(*commands)
    end

    def vm_hash
      return @vm_hash if @vm_hash
      @vm_hash = {}
      output = execute("VBoxManage", "showvminfo", @uuid, "--machinereadable")
      output.gsub("\"", "").split("\n").each do |attribute|
        key, value = attribute.split("=")
        @vm_hash[key] = value
      end
      @vm_hash
    end

  end
end
