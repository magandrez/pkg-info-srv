# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--display-cop-names']
end
RSpec::Core::RakeTask.new(:spec)

namespace :default do
  task :all do
    Rake::Task['rubocop'].invoke
    Rake::Task['spec'].invoke
  end
end
