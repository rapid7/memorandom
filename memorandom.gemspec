# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'memorandom/version'

Gem::Specification.new do |s|
  s.name        = 'memorandom'
  s.version     = Memorandom::VERSION
  s.authors     = [
      'Rapid7 Research'
  ]
  s.email       = [
      'research@rapid7.com'
  ]
  s.homepage    = "https://www.github.com/rapid7/memorandom"
  s.summary     = %q{Utility and library for extracting secrets from binary blobs}
  s.description = %q{
    Memorandom provides a command-line utility and class library from extracting secrets
    from binary files. Common use cases include extracting encryption keys from memory dumps
    and identifying sensitive data stored in block devices.
  }.gsub(/\s+/, ' ').strip

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # ---- Dependencies ----

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber' 
  s.add_development_dependency 'aruba'

  s.add_runtime_dependency 'credit_card_validator'
end
