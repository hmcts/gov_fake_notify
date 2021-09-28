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
  c.delivery_method = 'test'
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

## Configuration

Configuration can be done using the command line, a config file, environment variables or directly (in process only).
Note that the configuration can include an API key - do not be tempted to use the same value as the production environment
as the chances are it will end up in github which is publically accessible.

The following configuration entries are available

port
smtp_address
smtp_port
smtp_user_name
smtp_password
smtp_authentication
smtp_enable_starttls_auto
base_url
database_file
attachments_path
delivery_method
include_templates (config file or direct config only)
include_api_keys (config file or direct config only)

To configure via the command line - use the 'dash' version of the variable - for example

--smtp-port instead of smtp_port

To configure in the yaml file use the actual variable name

### An example yaml config file (from employment tribunals config)

```yaml
---
  port: 8081
  delivery_method: test
  include_templates:
  - id: a55e0b84-8d65-4bf4-93a7-e974e0d8d48d
    name: et1-confirmation-email-v1-en
    subject: "Employment tribunal: claim submitted"
    message: |
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
      
      ---
      
      Please use the link below to download a copy of your claim.
      ((link_to_pdf))
      
      ---
      
      Additional Information File
      
      ((link_to_additional_info))
      
      ---
      
      Group Claim File
      
      ((link_to_claimants_file))
      
      ---
      
      
      
      Your feedback helps us improve this service:
      https://www.gov.uk/done/employment-tribunals-make-a-claim
      
      Help us keep track. Complete our diversity monitoring questionnaire.
      https://employmenttribunals.service.gov.uk/en/apply/diversity
      
      Contact us: http://www.justice.gov.uk/contacts/hmcts/tribunals/employment
  - id: 97a117f1-727d-4631-bbc6-b2bc98d30a0f
    name: et1-confirmation-email-v1-cy
    subject: "Tribiwnlys Cyflogaeth: hawliad wedi’i gyflwyno"
    message: |
      Eich rhif hawliad: ((claim.reference))

      ((primary_claimant.first_name)) ((primary_claimant.last_name))
      Diolch am gyflwyno eich hawliad i dribiwnlys cyflogaeth.
      ---
      
      BETH SY'N DIGWYDD NESAF
      
      Byddwn yn cysylltu â chi unwaith y byddwn wedi anfon eich hawliad at yr atebydd i egluro beth fydd yn digwydd nesaf. Ar hyn o bryd, mae’n cymryd oddeutu 25 diwrnod.
      Unwaith y byddwn wedi anfon eich hawliad atynt, mae gan yr atebydd 28 diwrnod i ymateb.
      
      ---
      
      MANYLION CYFLWYNO
      
      Hawliad wedi'i gyflwyno:      Cyflwynwyd ar ((submitted_date))
      Swyddfa tribiwnlys:           Cymru, Tribiwnlys Cyflogaeth
      Cyswllt: ((office.email)), 0300 303 0654
      
      ---     
      
      Defnyddiwch y ddolen isod i lawrlwytho copi o’ch hawliad.
      ((link_to_pdf))
      
      ---
      
      Ffeil Gwybodaeth Ychwanegol
      
      ((link_to_additional_info))
      
      ---
      
      Hawliad Grŵp
      
      ((link_to_claimants_file))
      
      ---
      
      Mae eich adborth yn ein helpu i wella'r gwasanaeth hwn:
      https://www.gov.uk/done/employment-tribunals-make-a-claim
      
      Helpwch ni i gadw cofnodion cywir . Llenwch ein holiadur monitro amrywiaeth.
      https://employmenttribunals.service.gov.uk/en/apply/diversity
      
      Cysylltu â ni: http://www.justice.gov.uk/contacts/hmcts/tribunals/employment
  include_api_keys: 
  - service_name: Employment Tribunals
    service_email: employmenttribunals@email.com
    key: fake-key-7fc24bc8-1938-1827-bed3-fb237f9cd5e7-c34b3015-02a1-4e01-b922-1ea21f331d4d
    

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gov_fake_notify.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
