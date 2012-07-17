require 'sinatra'
require 'jbuilder'

module Cloudbox
  class Web < Sinatra::Base

    def vm_json(vms)
      Jbuilder.encode do |json|
        json.vms vms, :uuid, :name, :ostype, :memory, :ip_address, :macaddress1, :running?
      end
    end

    def generate_instance_id
      Cloudbox::Manager.uuid_generator.generate(:compact)[0..6]
    end

    at_exit do
      Cloudbox::Manager.cleanup
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
      instance_id = generate_instance_id
      Cloudbox::Manager.workers[instance_id] = Thread.new do
        vm = Cloudbox::VM.clone_from(uuid, true)
        if vm && vm.exists?
          vm.uuid
        else
          "Clone process was cancelled"
        end
      end
      Jbuilder.encode do |json|
        json.instance_id instance_id
      end
    end

    post "/clone" do
      uuid = params[:uuid]
      instance_id = generate_instance_id
      Cloudbox::Manager.workers[instance_id] = Thread.new do
        vm = Cloudbox::VM.clone_from(uuid)
        if vm && vm.exists?
          vm.uuid
        else
          "Clone process was cancelled"
        end
      end
      Jbuilder.encode do |json|
        json.instance_id instance_id
      end
    end

    get "/vm/:id" do
      thread = Cloudbox::Manager.workers[params[:id]]
      status = if thread
        if thread.alive?
          "Provisioning"
        else
          if thread.value.nil?
            "Something went wrong"
          else
            @vm = Cloudbox::VM.new(thread.value)
            @vm.running? ? "VM Running" : "VM Ready"
          end
        end
      else
        @vm = Cloudbox::VM.new(thread.value)
        @vm.running? ? "VM Running" : "VM Ready"
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
