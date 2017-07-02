# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll/quicklatex/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-quicklatex"
  spec.version       = Jekyll::Quicklatex::VERSION
  spec.authors       = ["DreamAndDead"]
  spec.email         = ["aquairain@gmail.com"]

  spec.summary       = %q{a jekyll converter plugin for latex tikz.}
  spec.description   = %q{jekyll-quicklatex, a jekyll converter plugin for latex tikz.}
  spec.homepage      = "https://github.com/DreamAndDead/jekyll-quicklatex"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "jekyll", "~> 3.0"
end
