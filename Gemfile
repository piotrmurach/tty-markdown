source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

if RUBY_VERSION == "2.0.0"
  gem "json", "2.4.1"
  gem "kramdown", "1.16.2"
end

group :test do
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.1.0")
    gem "rspec-benchmark", "~> 0.6"
  end
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.5.0")
    gem "coveralls_reborn", "~> 0.22.0"
    gem "simplecov", "~> 0.21.0"
  end
  gem "yardstick", "~> 0.9.9"
end
