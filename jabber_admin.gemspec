# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jabber_admin/version'

Gem::Specification.new do |spec|
  spec.name = 'jabber_admin'
  spec.version = JabberAdmin::VERSION
  spec.authors = ['Hermann Mayer', 'Henning Vogt']
  spec.email = ['hermann.mayer92@gmail.com', 'henning.vogt@hausgold.de']

  spec.license = 'MIT'
  spec.summary = 'Library for the ejabberd RESTful admin API'
  spec.description = 'Library for the ejabberd RESTful admin API'

  base_uri = "https://github.com/hausgold/#{spec.name}"
  spec.metadata = {
    'homepage_uri' => base_uri,
    'source_code_uri' => base_uri,
    'changelog_uri' => "#{base_uri}/blob/master/CHANGELOG.md",
    'bug_tracker_uri' => "#{base_uri}/issues",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{spec.name}"
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'activesupport', '>= 5.2'
  spec.add_dependency 'rest-client', '~> 2.1'

  spec.add_development_dependency 'appraisal', '~> 2.4'
  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'countless', '~> 1.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'irb', '~> 1.2'
  spec.add_development_dependency 'railties', '>= 5.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.28'
  spec.add_development_dependency 'rubocop-rails', '~> 2.14'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.10'
  spec.add_development_dependency 'simplecov', '>= 0.22'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.18'
  spec.add_development_dependency 'yard', '>= 0.9.28'
  spec.add_development_dependency 'yard-activesupport-concern', '>= 0.0.1'
end
