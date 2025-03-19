# frozen_string_literal: true

require "bundler/gem_tasks"

FileList["tasks/**/*.rake"].each { |task| import(task) }

desc "Run all specs"
task ci: %w[spec]

task default: :spec
