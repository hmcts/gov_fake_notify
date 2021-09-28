# GovFakeNotify

This gem provides a standalone tool which emulates the real govuk notify service.  It is intended for test and development environments only.

IMPORTANT: Whilst this tool can send real emails via SMTP, this is intended for use during development and test only - ideally using something 
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

### Command Line Usage

If the gem is being used as part of a full stack test suite (i.e. the emails are being sent in a different process to the tests), it can be used as
a command line tool like this

gov_fake_notify start -c ./config.json

which will start the server using the config file provided (see configuration below)

#### Test Suite Configuration

There are 2 ways of validating emails using this gem - either allow the gem to send real emails to a fake smtp server such as mailhog
OR dont send emails at all and use the 'notifications-ruby-client' to read from the API provided by this gem to see what emails would
have been sent.

Please see the configuration section below to see how to switch modes etc..

### In Process Usage

if the gem is being used as part of a test suite where the code under test is in the same process as the tests, it can be used alongside 'webmock'
as follows :-


#### In a spec/support/*.rb file OR in rails_helper.rb etc..

This is a partial example from the employment tribunals test suite

```ruby
require 'gov_fake_notify'
RSpec.configure do |c|
  c.before(:each) do
    GovFakeNotify.reset!
  end
end
GovFakeNotify.config do |c|
  c.delivery_method = :test
  c.include_templates = [
    {
      id: 'a55e0b84-8d65-4bf4-93a7-e974e0d8d48d', # Note - does not need to be exact id that is used in govuk notify UNLESS 
      name: 'et1-confirmation-email-v1-en',       #  your system has hard coded id's or referenced by environment variables etc..
      subject: 'Employment tribunal: claim submitted',
      message: <<~EOS
        Claim number: ((claim.reference))

        ((primary_claimant.first_name)) ((primary_claimant.last_name))
        
        Thank you for submitting your claim to an employment tribunal.
        
        ---
        
        WHAT HAPPENS NEXT
        
        We'll contact you once we have sent your claim to the respondent and explain what happens next.
        At present, this is taking us an average of 25 days.
        Once we have sent them your claim, the respondent has 28 days to reply.
        
        ---
        
        SUBMISSION DETAILS
        
        Claim submitted:       ((submitted_date))
        Tribunal office:       ((office.name))
        Contact: ((office.email)), ((office.telephone))
        
        Your feedback helps us improve this service:
        https://www.gov.uk/done/employment-tribunals-make-a-claim
        
        Contact us: http://www.justice.gov.uk/contacts/hmcts/tribunals/employment
      EOS

    }
  ]
  c.include_api_keys = [
    {
      service_name: 'Employment Tribunals',
      service_email: 'employmenttribunals@email.com',
      key: 'fake-key-7fc24bc8-1938-1827-bed3-fb237f9cd5e7-c34b3015-02a1-4e01-b922-1ea21f331d4d' # Your application under test's key - 
                                                                                                #   the keys must match.    
    }
  ]
end
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gov_fake_notify.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
