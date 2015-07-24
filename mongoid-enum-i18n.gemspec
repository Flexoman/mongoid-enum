# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid/enum/version'

Gem::Specification.new do |spec|
  spec.name          = "mongoid-enum-i18n"
  spec.version       = Mongoid::Enum::VERSION
  spec.authors       = ["Nicholas Bruning", "Marcos Piccinini"]
  spec.email         = ["nicholas@bruning.com.au"]
  spec.description   = %q{Heavily inspired by DDH's ActiveRecord::Enum, this little library is there to help you cut down the cruft in your models and make the world a happier place at the same time.}
  spec.summary       = %q{Sweet enum sugar for your Mongoid documents}
  spec.homepage      = "https://github.com/thetron/mongoid-enum"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mongoid", "> 4.0.0"
end
