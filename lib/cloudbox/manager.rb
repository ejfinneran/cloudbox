require 'uuid'

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
      command.error!
      command.stdout
    end

    def self.workers
      @@workers ||= {}
    end

    def self.uuid_generator
      @@uuid_generator ||= UUID.new
    end

    def self.cleanup
      workers = self.workers.values.compact
      if workers.detect(&:alive?)
        # The VBoxManage command will also receive the SIGINT and cancel any active clones.
        # We just need to wait for it to finish
        puts "Allowing workers to halt and cleanup..."
        workers.each(&:join)
        puts "Done!"
      end
    end


  end
end
