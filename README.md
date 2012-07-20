# Cloudbox

A stupid simple HTTP API on top of VirtualBox. The design goal for this is an API simple enough to use via Curl.

## Features ##

* No external dependencies aside from VBox
* Can clone from an existing VirtualBox VM
* Can start/stop/destroy VM

## Usage

Make sure [VirtualBox](http://www.virtualbox.org) is installed and create a template image with bridged networking enabled and VBox Guest Additions.

In this example, We'll be using an Ubuntu 10.04 image.

#### Start the server ####
    bundle --without test
    rackup

#### List VMs ####
    $ curl http://localhost:9292/vms
    {
        "vms": [
            {
                "ip_address": "",
                "macaddress1": "0800274153F3",
                "memory": "384",
                "name": "lucid32",
                "ostype": "Ubuntu",
                "running?": false,
                "uuid": "c880a82c-e02c-4dbd-99e1-3d1d5bc560ae"
            }
        ]
    }
#### Clone a VM ####
    $ curl -d '' http://localhost:9292/vms/lucid32/clone
    {
        "instance_id": "1c68b8"
    }

#### Check VM status ####

    $ curl http://localhost:9292/vms/1c68b8
    {
        "status": "Provisioning"
    }

    $ curl http://localhost:9292/vms/1c68b8
    {
        "status": "VM Ready",
        "vm": {
            "ip_address": "",
            "macaddress1": "080027E0DDA4",
            "memory": "384",
            "name": "1c68b8",
            "ostype": "Ubuntu",
            "running?": false,
            "uuid": "ecf59846-040b-426a-a10c-c065ee1e76f1"
        }
    }

#### Start the new VM ####

    $ curl -d '' http://localhost:9292/vms/1c68b8/start
    {
        "response": "VM Started"
    }

Note that the IP address may take few moments to be populated.  It also requires that VirtualBox Guest Additions are installed on the guest.

    $ curl http://localhost:9292/vms/1c68b8
    {
        "status": "VM Running",
        "vm": {
            "ip_address": "10.0.1.35",
            "macaddress1": "080027E0DDA4",
            "memory": "384",
            "name": "1c68b8",
            "ostype": "Ubuntu",
            "running?": true,
            "uuid": "ecf59846-040b-426a-a10c-c065ee1e76f1"
        }
    }

## Roadmap/Known Issues ##
?
* Ability to set a default "clone from" image
* In order to use CentOS, the base image needs some [extra setup.](http://www.cyberciti.biz/tips/vmware-linux-lost-eth0-after-cloning-image.html)
* More config options when cloning a VM (Memory etc)

## Contributing ##

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
