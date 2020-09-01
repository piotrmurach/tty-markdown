source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

if RUBY_VERSION.split(".")[1].to_i > 0
  gem "rspec-benchmark", "~> 0.6"
end

group :test do
  gem "simplecov", "~> 0.16.1"
  gem "coveralls", "~> 0.8.22"
  gem "yardstick", "~> 0.9.9"
end
