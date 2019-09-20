# frozen_string_literal: true

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--display-cop-names']
end

namespace :default do
  task :rubocop do
    Rake::Task['rubocop'].invoke
  end
end
