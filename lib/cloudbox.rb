require "cloudbox/version"
require "mixlib/shellout"
require "cloudbox/exceptions"

module Cloudbox
  autoload :VM, "cloudbox/vm"
  autoload :Manager, "cloudbox/manager"
  autoload :Web, "cloudbox/web"
end
