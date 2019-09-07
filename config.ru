require 'bundler/setup'
Bundler.require

require_relative 'lib/file_parser.rb'
require_relative 'app/controllers/app_controller.rb'
require_relative 'app/models/package.rb'

run AppController
