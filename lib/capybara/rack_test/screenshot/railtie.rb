if defined?(ActiveSupport)
  require 'action_dispatch/system_testing/test_helpers/screenshot_helper'
  module ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper
    def supports_screenshot?
      true
    end
  end
end
