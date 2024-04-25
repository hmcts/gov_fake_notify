# frozen_string_literal: true

require_relative 'lib/gov_fake_notify/version'

Gem::Specification.new do |spec|
  spec.name          = 'gov_fake_notify'
  spec.version       = GovFakeNotify::VERSION
  spec.authors       = ['garytaylor']
  spec.email         = ['gary.taylor@hismessages.com']

  spec.summary       = 'A fake govuk notify service'
  spec.description   = 'A fake govuk notify service that sends emails via smtp for ease of testing'
  spec.homepage      = 'https://github.com/hmcts/gov_fake_notify'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/hmcts/gov_fake_notify'
  spec.metadata['changelog_uri'] = 'https://github.com/hmcts/gov_fake_notify/changelog.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '>= 6.1'
  spec.add_dependency 'puma', '~> 6.4'
  spec.add_dependency 'jwt', '~> 2.2', '>= 2.2.3'
  spec.add_dependency 'mail', '~> 2.7', '>= 2.7.1'
  spec.add_dependency 'roda', '~> 3.48'
  spec.add_dependency 'tilt', '~> 2.0', '>= 2.0.10'

  spec.add_dependency 'thor', '~> 1.1'

  spec.add_development_dependency 'rubocop', '~> 1.21'
end
