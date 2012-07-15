# Cloudbox

A stupid simple HTTP API on top of VirtualBox. The design goal for this is an API simple enough to use via Curl.

## Features ##

* Can clone from an existing VirtualBox VM
* Can start/stop/destroy VM

## Usage

Make sure [VirtualBox](http://www.virtualbox.org) is installed and create a template image with bridged networking enabled.

In this example, We'll be using an Ubuntu 10.04 image.

#### Start the server ####
    bundle
    rackup

#### List VMs ####
    $ curl http://localhost:9292/vms
    {
        "vms": [
            {
                "ip_address": "",
                "macaddress1": "0800274153F3",
                "memory": "384",
                "name": "luci32",
                "ostype": "Ubuntu",
                "running?": false,
                "uuid": "c880a82c-e02c-4dbd-99e1-3d1d5bc560ae"
            }
        ]
    }
#### Clone a VM ####
    $ curl -d "uuid=c880a82c-e02c-4dbd-99e1-3d1d5bc560ae" http://localhost:9292/clone
    {
        "job_id": "1c68b8c0b014012fc39a388d120ed38a"
    }

#### Check cloning status ####

    $ curl http://localhost:9292/status/1c68b8c0b014012fc39a388d120ed38a
    {
        "status": "Running"
    }

#### Get new VM info ####

Note, that the `ip_address` field may take a little longer to populate than the other fields.

    $ curl http://localhost:9292/status/1c68b8c0b014012fc39a388d120ed38a
    {
        "status": "VM Ready",
        "vm": {
            "ip_address": "10.0.1.35",
            "macaddress1": "080027E0DDA4",
            "memory": "384",
            "name": " Clone",
            "ostype": "RedHat_64",
            "running?": true,
            "uuid": "ecf59846-040b-426a-a10c-c065ee1e76f1"
        }
    }

#### Start the new VM ####

    $ curl -d "uuid=1b4a1d8a-1799-4891-86dc-dd8dc309d8c9" http://localhost:9292/start
    {
        "response": "VM Started"
    }
## Installation

Add this line to your application's Gemfile:

    gem 'cloudbox'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudbox

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
