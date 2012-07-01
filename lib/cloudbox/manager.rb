module Cloudbox
  class Manager
    def self.vms
      output = execute("VBoxManage", "list", "vms")
      Cloudbox::VM.from_list(output)
    end

    def self.running_vms
      output = execute("VBoxManage", "list", "runningvms")
      Cloudbox::VM.from_list(output)
    end

    def self.execute(*commands)
      command = Mixlib::ShellOut.new(*commands)
      command.run_command
      command.stdout
    end
  end
end
