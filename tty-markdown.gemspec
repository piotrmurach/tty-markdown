# frozen_string_literal: true

require_relative "lib/tty/markdown/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-markdown"
  spec.version       = TTY::Markdown::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = %q{Convert a markdown text or document into a terminal friendly output.}
  spec.description   = %q{Convert a markdown text or document into a terminal friendly output.}
  spec.homepage      = "https://ttytoolkit.org"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"]
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "kramdown",   ">= 1.16.2", "< 3.0"
  spec.add_dependency "pastel",     "~> 0.8"
  spec.add_dependency "rouge",      "~> 3.14"
  spec.add_dependency "strings",    "~> 0.2.0"
  spec.add_dependency "tty-color",  "~> 0.5"
  spec.add_dependency "tty-screen", "~> 0.8"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
