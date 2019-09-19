require 'bundler/setup'
Bundler.require(:default)

require_relative 'lib/file_parser'
require_relative 'app/app'

run App
