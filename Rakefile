# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :playwright do
  desc "Install Playwright browsers"
  task :install do
    require "playwright"
    system "npx playwright@#{Playwright::COMPATIBLE_PLAYWRIGHT_VERSION} install --with-deps chromium",
      exception: true,
      err: '/dev/null'
  end
end

task default: %i[playwright:install spec]
