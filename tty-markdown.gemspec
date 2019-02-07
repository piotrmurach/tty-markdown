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

  spec.files         = Dir['{lib,spec,examples}/**/*.rb']
  spec.files        += Dir['{bin,assets,tasks}/*', 'tty-spinner.gemspec']
  spec.files        += Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt', 'Rakefile']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency "kramdown",   '~> 1.16.2'
  spec.add_dependency "pastel",     '~> 0.7.2'
  spec.add_dependency "rouge",      '~> 3.3'
  spec.add_dependency "strings",    '~> 0.1.4'
  spec.add_dependency "tty-color",  '~> 0.4'
  spec.add_dependency "tty-screen", '~> 0.6'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
