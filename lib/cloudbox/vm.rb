module Cloudbox
  class VM

    def initialize(uuid)
      @uuid = uuid
      raise "Not found" unless self.uuid
    end

    class << self

      def clone_from(uuid, name, boot = false)
        old_vms = Cloudbox::Manager.vms
        begin
          output = Cloudbox::Manager.execute("VBoxManage", "clonevm", uuid, "--register", "--name", name)
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

      def find(uuid)
        Cloudbox::Manager.vms.detect {|vm| vm.uuid == uuid || vm.name == uuid }
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
      self.vmstate == 'running'
    end

    def method_missing(method, *args)
      if vm_hash[method.to_s]
        return vm_hash[method.to_s]
      else
        # Pass on to the superclass unless the user is calling identifying fields
        super unless ["name", "uuid"].include?(method)
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
        @vm_hash[key.downcase] = value
      end
      @vm_hash
    rescue # VM probably isn't ready yet
      {}
    end

  end
end
