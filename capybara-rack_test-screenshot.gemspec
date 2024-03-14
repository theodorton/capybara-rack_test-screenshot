# frozen_string_literal: true

require_relative "lib/capybara/rack_test/screenshot/version"

Gem::Specification.new do |spec|
  spec.name = "capybara-rack_test-screenshot"
  spec.version = Capybara::RackTest::Screenshot::VERSION
  spec.authors = ["Theodor Tonum"]
  spec.email = ["theodor@tonum.no"]

  spec.summary = "Screenshots for RackTest"
  spec.description = "Use playwright to generate screenshots when using RackTest"
  spec.homepage = "https://github.com/theodorton/capybara-rack_test-screenshot"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/theodorton/capybara-rack_test-screenshot"
  spec.metadata["changelog_uri"] = "https://github.com/theodorton/capybara-rack_test-screenshot/blob/main/CHANGELOG.md"

  spec.add_dependency "capybara", "~> 3.0"
  spec.add_dependency "playwright-ruby-client", "~> 1.16"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
end
