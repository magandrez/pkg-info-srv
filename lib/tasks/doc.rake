# frozen_string_literal: true

namespace :doc do
  require 'yard'
  YARD::Rake::YardocTask.new do |task|
    task.files = ['app/*.rb', 'lib/*.rb']
    task.options = ['--private']
  end
end
