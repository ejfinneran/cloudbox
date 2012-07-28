require 'sinatra'
require File.expand_path(File.dirname(__FILE__) + '/lib/cloudbox')
set :app_file, File.expand_path(File.dirname(__FILE__) + '/lib/cloudbox/web.rb')
set :env,      :production
disable :run, :reload
require File.dirname(__FILE__) + "/lib/cloudbox/web.rb"
run Cloudbox::Web
