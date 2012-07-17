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
        vm = Cloudbox::VM.clone_from(uuid, instance_id, true)
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
        vm = Cloudbox::VM.clone_from(uuid, instance_id)
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

    # Fetch the status of the VM with name == :id.
    # We first match sure that we can find either a VM or a thread matching the given ID. If not, 404.
    # If that thread exists we interrogate its state and figure out what to tell the user
    # If it


    # Possible states
    # - Thread exists, VM does not
    # - Thread exists, VM exists
    # - Thread exists, VM exists
    # - Thread does not exists, VM does
    # - Thread does not exist, VM does not
    get "/vm/:id" do
      @vm = Cloudbox::VM.find(params[:id])
      thread = Cloudbox::Manager.workers[params[:id]]
      if !(@vm || thread)
        return [404, {:status => "VM Not Found"}.to_json]
      elsif thread
        if thread.alive?
          return [200, {:status => "Provisioning"}.to_json]
        elsif thread.value.nil?
          return [500, {:status => "Something went wrong"}.to_json]
        end
      end
      Jbuilder.encode do |json|
        json.status @vm.running? ? "VM Running" : "VM Ready"
        json.vm @vm, :uuid, :name, :ostype, :memory, :ip_address, :macaddress1, :running?
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
