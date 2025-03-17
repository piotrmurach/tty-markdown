# frozen_string_literal: true

require_relative "lib/tty/markdown/version"

Gem::Specification.new do |spec|
  spec.name = "tty-markdown"
  spec.version = TTY::Markdown::VERSION
  spec.authors = ["Piotr Murach"]
  spec.email = ["piotr@piotrmurach.com"]
  spec.summary = "Convert a Markdown text or document into a terminal friendly output."
  spec.description = "Convert a Markdown text or document into a terminal friendly output."
  spec.homepage = "https://ttytoolkit.org"
  spec.license = "MIT"
  if spec.respond_to?(:metadata=)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/tty-markdown/issues"
    spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/tty-markdown/blob/master/CHANGELOG.md"
    spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/tty-markdown"
    spec.metadata["funding_uri"] = "https://github.com/sponsors/piotrmurach"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["rubygems_mfa_required"] = "true"
    spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/tty-markdown"
  end
  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "kramdown", ">= 1.16.2", "< 3.0"
  spec.add_dependency "pastel", "~> 0.8"
  spec.add_dependency "rouge", ">= 3.14", "< 5.0"
  spec.add_dependency "strings", "~> 0.2.0"
  spec.add_dependency "tty-color", "~> 0.6"
  spec.add_dependency "tty-screen", "~> 0.8"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
