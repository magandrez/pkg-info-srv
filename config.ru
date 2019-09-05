require 'bundler/setup'
Bundler.require

require './app/controllers/app_controller.rb'
require './app/models/package.rb'

run AppController
