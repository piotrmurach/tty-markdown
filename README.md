# TTY::Markdown [![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]

[![Gem Version](https://badge.fury.io/rb/tty-markdown.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-markdown.svg?branch=master)][travis]
[![Build status](https://ci.appveyor.com/api/projects/status/k4vub4koct329ggd?svg=true)][appveyor]
[![Maintainability](https://api.codeclimate.com/v1/badges/1656060107c73ac42c2b/maintainability)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-markdown/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-markdown.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/tty
[gem]: http://badge.fury.io/rb/tty-markdown
[travis]: http://travis-ci.org/piotrmurach/tty-markdown
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-markdown
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-markdown/maintainability
[coverage]: https://coveralls.io/github/piotrmurach/tty-markdown
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-markdown

> Convert a markdown documet or text into a terminal friendly output.


**TTY::Markdown** provides independent markdown processing component for [TTY](https://github.com/piotrmurach/tty) toolkit.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-markdown'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-markdown

## Usage

Using `parse` method, you can transform a markdown string into a terminal formatted content:

```ruby
parsed = TTY::Markdown.parse("# Hello")
puts parsed
# => "\e[36;1mHello\e[0m\n"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tty-markdown. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tty::Markdown project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/tty-markdown/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2018 Piotr Murach. See LICENSE for further details.
