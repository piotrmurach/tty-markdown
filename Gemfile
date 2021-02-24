source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.1.0")
  gem "rspec-benchmark", "~> 0.6"
end
gem "json", "2.4.1" if RUBY_VERSION == "2.0.0"

group :test do
  gem "simplecov", "~> 0.16.1"
  gem "coveralls", "~> 0.8.22"
  gem "yardstick", "~> 0.9.9"
end
