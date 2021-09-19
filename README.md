# GovFakeNotify

This gem provides a standalone tool which emulates the real govuk notify service.  It is intended for test and development environments only.

IMPORTANT: Whilst this tool sends real emails via SMTP, this is intended for use during development and test only - ideally using something 
  like 'mailhog' instead of a real SMTP server.

  If you have set it up with a real SMTP server, please ensure that the service is NOT exposed to the internet.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gov_fake_notify'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install gov_fake_notify

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gov_fake_notify.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
