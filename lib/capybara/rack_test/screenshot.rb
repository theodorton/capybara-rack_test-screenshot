# frozen_string_literal: true

require 'capybara'
require 'playwright'
require_relative "screenshot/version"

module Capybara
  module RackTest
    module Screenshot
      class << self
        attr_reader :default_viewport
        attr_accessor :viewport, :base_url

        def default_viewport=(viewport)
          @default_viewport = viewport
          reset_viewport!
        end

        def save_screenshot(path, driver, **options)
          ensure_asset_host!

          with_html_page(driver) do |page_path|
            page = browser.new_page(viewport: viewport, javaScriptEnabled: false)
            page.goto("file://#{page_path}")
            page.screenshot(path: path)
            page.close
          end
        end

        def preload!
          Thread.new do
            browser_semaphore.synchronize do
              @browser = create_browser
            end
          end
        end

        def reset_viewport!
          self.viewport = default_viewport
        end

        private

        attr_accessor :browser_semaphore

        def browser
          browser_semaphore.synchronize do
            @browser ||= create_browser
          end
        end

        def create_browser
          pw = ::Playwright.create(playwright_cli_executable_path: playwright_cli_executable_path)
          browser = pw.playwright.chromium.launch(headless: true, args: ['--disable-web-security'])
          at_exit { pw.stop }
          browser
        end

        def with_html_page(driver, &blk)
          Tempfile.create(['capybara-screenshot', '.html']) do |tempfile|
            page_path = tempfile.path
            html = Capybara::Helpers.inject_asset_host(driver.html, host: Capybara.asset_host)
            File.write(page_path, html, mode: 'wb')

            yield page_path
          end
        end

        def playwright_cli_executable_path
          ENV['PLAYWRIGHT_CLI_EXE_PATH'] || begin
            version = Gem::Version.create(Playwright::COMPATIBLE_PLAYWRIGHT_VERSION)
            "npx playwright@#{version.release}"
          end
        end

        def ensure_asset_host!
          if Capybara.asset_host.nil?
            raise <<~ERR
              Please configure Capybara.asset_host to point to a server where the
              assets can be found. This is necessary to generate a screenshot.

              Example:

              Capybara.asset_host = 'http://localhost:3000'

              or

              Capybara.configure do |config|
                config.asset_host = 'http://localhost:3000'
              end
            ERR
          end
        end
      end

      self.default_viewport = { width: 1400, height: 1400 }
      self.browser_semaphore = Mutex.new
    end
  end
end

class Capybara::RackTest::Driver < Capybara::Driver::Base
  def save_screenshot(path, **options)
    Capybara::RackTest::Screenshot.save_screenshot(path, self, **options)
  end
end

if defined?(Rails)
  require_relative 'screenshot/railtie'
end

if defined?(Capybara::Screenshot)
  Capybara::Screenshot.register_driver(:rack_test) do |driver, path|
    driver.save_screenshot(path)
  end
end
