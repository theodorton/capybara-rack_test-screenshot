require 'spec_helper'
require 'capybara/rspec'
require 'mini_magick'

HelloWorld = Rack::Builder.new do
  map "/" do
    run ->(env) {[404, {'Content-Type' => 'text/plain'}, ['Page Not Found!']] }
  end
end

Capybara.app = HelloWorld
Capybara.configure do |config|
  config.save_path = 'tmp'
end

Capybara::RackTest::Screenshot.preload!

RSpec.describe Capybara::RackTest::Screenshot, type: :feature do
  before(:each) do
    Capybara.asset_host = 'http://localhost:3000'
  end

  after(:each) do
    Capybara::RackTest::Screenshot.default_viewport = { width: 1400, height: 1400 }
  end

  it 'works' do
    page.visit '/'
    page.save_screenshot
  end

  it 'uses 1400x1400 as default viewport' do
    page.visit '/'
    path = page.save_screenshot
    image = MiniMagick::Image.open(path)
    expect(image.width).to eq(1400)
    expect(image.height).to eq(1400)
  end

  it 'can change viewport' do
    Capybara::RackTest::Screenshot.viewport = { width: 800, height: 600 }
    page.visit '/'
    path = page.save_screenshot
    image = MiniMagick::Image.open(path)
    expect(image.width).to eq(800)
    expect(image.height).to eq(600)
  end

  it 'can change the default_viewport' do
    Capybara::RackTest::Screenshot.default_viewport = { width: 800, height: 600 }
    Capybara::RackTest::Screenshot.viewport = { width: 200, height: 200 }
    Capybara::RackTest::Screenshot.reset_viewport!
    expect(Capybara::RackTest::Screenshot.viewport).to eq(width: 800, height: 600)
  end

  it 'fails if asset host is not set' do
    Capybara.asset_host = nil
    expect { page.save_screenshot }.to raise_error(/Please configure Capybara.asset_host/)
  end

  it "makes Rails believe that Rack supports_screenshot? option 1" do
    pid = Process.fork do
      require 'rails'
      require 'capybara/rack_test/screenshot/railtie'
      require 'action_dispatch/system_test_case'

      klass = Class.new
      klass.include(ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper)
      expect(klass.new.send(:supports_screenshot?)).to be_truthy
    end

    expect(Process::Status.wait(pid)).to be_success
  end

  it 'makes Rails believe that Rack supports_screenshot? option 2' do
    pid = Process.fork do
      require 'rails'
      require 'capybara/rack_test/screenshot/railtie'
      require 'action_dispatch/system_testing/test_helpers/screenshot_helper'

      klass = Class.new
      klass.include(ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper)
      expect(klass.new.send(:supports_screenshot?)).to be_truthy
    end

    expect(Process::Status.wait(pid)).to be_success
  end

  it 'can preload a browser instance without crashing' do
    expect { Capybara::RackTest::Screenshot.preload! }.not_to raise_error
  end
end
