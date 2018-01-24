lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tty/markdown/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-markdown"
  spec.version       = TTY::Markdown::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = []

  spec.summary       = %q{Convert a markdown text or document into a terminal friendly output.}
  spec.description   = %q{Convert a markdown text or document into a terminal friendly output.}
  spec.homepage      = "https://piotrmurach.github.io/tty"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "kramdown",  '~> 1.16.2'
  spec.add_dependency "pastel",    '~> 0.7.2'
  spec.add_dependency "rouge",     '~> 3.1.0'
  spec.add_dependency "strings",   '~> 0.1.0'
  spec.add_dependency "tty-color", '~> 0.4.2'
  spec.add_dependency "tty-screen", '~> 0.6.2'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
