lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "geom_craft/version"

Gem::Specification.new do |spec|
  spec.name          = "geom_craft"
  spec.version       = GeomCraft::VERSION
  spec.authors       = ["akicho8"]
  spec.email         = ["akicho8@gmail.com"]
  spec.description   = %q{This is a Ruby library inspired by the Rect and 2D vector libraries used in the Rust Nannou framework}
  spec.summary       = %q{This is a Ruby library inspired by the Rect and 2D vector libraries used in the Rust Nannou framework}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "test-unit"
end
