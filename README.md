[![Gem Version](https://badge.fury.io/rb/capybara-rack_test-screenshot.svg)](https://rubygems.org/gems/capybara-rack_test-screenshot)

# Generate screenshots with RackTest

Makes `save_screenshot` behave as if you were using a regular browser when using `rack` as your Capybara driver.

Will by default render pages in a 1400x1400 viewport.

Generates screenshots using [playwright-ruby-client](https://github.com/YusukeIwaki/playwright-ruby-client).

Very useful for showing screenshots on failed examples like this:

```rb
RSpec.configure do |config|
  config.after(:each) do |example|
    if example.exception
      path = save_screenshot
      puts "Screenshot at #{path}"
    end
  end

  # Or for Rails projects
  config.after(:each) do |example|
    if example.exception
      take_screenshot(screenshot: 'inline')
    end
  end
end
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add capybara-rack_test-screenshot --group test

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install capybara-rack_test-screenshot

## Configuration

You'll need to configure `Capybara.asset_host` in order for Playwright to render the page properly. This should point to a running development server of your application.

```rb
Capybara.asset_host = "http://localhost:3000"
```

Optional settings:

```rb
Capybara::RackTest::Screenshot.viewport = { width: 1920, height: 1080 }

Capybara::RackTest::Screenshot.default_viewport = { width: 1920, height: 1080 }
# See Viewports below for details
```

In some cases, it might make sense to preload the playwright browser used for screenshots:

```rb
Capybara::RackTest::Screenshot.preload!
```

You can override the path to the playwright binary by setting `PLAYWRIGHT_CLI_EXE_PATH`. By default the gem will call `npx playwright`.

## Usage

Then use `save_screenshot` in your tests as if you were using any JS enabled driver.

```rb
example "my browser test" do
  page.visit "http://example.com"
  page.save_screenshot
end
```

### Viewports

In some cases, you might have different viewports for different tests.

If you have some default viewport you'd prefer to use, configure that with `default_viewport` and set `viewport` close to where you declare the viewport for your driver. Before (or after) each test, call `Capybara::RackTest::Screenshot.reset_viewport!` to revert to the default.

```rb
Capybara::RackTest::Screenshot.default_viewport = { width: 1920, height: 1080 }

RSpec.configure do |config|
  config.before(:each, type: :system, mobile: true) do
    driven_by :rack, options: { viewport: { width: 375, height: 812 } }
    Capybara::RackTest::Screenshot.viewport = { width: 375, height: 812 }
  end

  config.after(:each) do
    Capybara::RackTest::Screenshot.reset_viewport!
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/theodorton/capybara-rack_test-screenshot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/theodorton/capybara-rack_test-screenshot/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Capybara::RackTest::Screenshot project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/theodorton/capybara-rack_test-screenshot/blob/main/CODE_OF_CONDUCT.md).
