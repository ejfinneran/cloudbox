require 'sinatra'
require 'jbuilder'
require 'uuid'
require 'logger'

module Cloudbox
  class Web < Sinatra::Base

    def self.workers
      @@workers ||= {}
    end

    def self.uuid_generator
      @@uuid_generator ||= UUID.new
    end

    def vm_json(vms)
      Jbuilder.encode do |json|
        json.vms vms, :uuid, :name, :ostype, :memory, :ip_address, :macaddress1, :running?
      end
    end

    at_exit do
      workers = Cloudbox::Web.workers.values.compact
      if workers.detect(&:alive?)
        # The VBoxManage command will also receive the SIGINT and cancel any active clones.
        # We just need to wait for it to finish
        puts "Allowing workers to halt and cleanup..."
        workers.each(&:join)
        puts "Done!"
      end
    end

    before do
      if params[:uuid]
        uuid = params[:uuid]
        @vm = Cloudbox::VM.new(uuid)
        unless @vm && @vm.exists?
          halt 404, Jbuilder.encode {|json| json.error "VM does not exist"}
        end
      end
    end

    get "/vms" do
      vms = Cloudbox::Manager.vms
      vm_json(vms)
    end

    get "/running_vms" do
      vms = Cloudbox::Manager.running_vms
      vm_json(vms)
    end

    post "/start" do
      @vm.start!("gui")
      Jbuilder.encode do |json|
        json.response "VM Started"
      end
    end

    post "/halt" do
      @vm.halt!
      Jbuilder.encode do |json|
        json.response "VM Halted"
      end
    end

    post "/clone_and_boot" do
      uuid = params[:uuid]
      job_id = Cloudbox::Web.uuid_generator.generate(:compact)
      Cloudbox::Web.workers[job_id] = Thread.new do
        vm = Cloudbox::VM.clone_from(uuid, true)
        if vm && vm.exists?
          vm.uuid
        else
          "Clone process was cancelled"
        end
      end
      Jbuilder.encode do |json|
        json.job_id job_id
      end
    end

    post "/clone" do
      uuid = params[:uuid]
      job_id = Cloudbox::Web.uuid_generator.generate(:compact)
      Cloudbox::Web.workers[job_id] = Thread.new do
        vm = Cloudbox::VM.clone_from(uuid)
        if vm && vm.exists?
          vm.uuid
        else
          "Clone process was cancelled"
        end
      end
      Jbuilder.encode do |json|
        json.job_id job_id
      end
    end

    get "/status/:job_id" do
      thread = Cloudbox::Web.workers[params[:job_id]]
      status = "Job not found" unless thread
      status ||= if thread.alive?
        "Running"
      else
        if thread.value.nil?
          "Something went wrong"
        else
          @vm = Cloudbox::VM.new(thread.value)
          "VM Ready"
        end
      end
      Jbuilder.encode do |json|
        json.status status
        json.vm @vm, :uuid, :name, :ostype, :memory, :ip_address, :macaddress1, :running? if @vm
      end
    end

    post "/destroy" do
      @vm.destroy!
      Jbuilder.encode do |json|
        json.response "VM Destroyed"
      end
    end

  end
end
