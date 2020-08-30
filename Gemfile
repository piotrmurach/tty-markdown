source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

if RUBY_VERSION.split(".")[1].to_i > 0
  gem "rspec-benchmark", "~> 0.6"
end

group :test do
  gem 'benchmark-ips', '~> 2.7.2'
  gem 'simplecov', '~> 0.16.1'
  gem 'coveralls', '~> 0.8.22'
end

group :metrics do
  gem 'yard',      '~> 0.9.12'
  gem 'yardstick', '~> 0.9.9'
end
