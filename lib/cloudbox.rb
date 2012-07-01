require "cloudbox/version"

module Cloudbox
  autoload :VM, "cloudbox/vm"

  def self.vms
    output = execute("VBoxManage", "list", "vms").stdout
    Cloudbox::VM.from_list(output)
  end

  def self.running_vms
    output = execute("VBoxManage", "list", "runningvms").stdout
    Cloudbox::VM.from_list(output)
  end

  def self.execute(*commands)
    command = Mixlib::ShellOut.new(*commands)
    command.run_command
  end

end
