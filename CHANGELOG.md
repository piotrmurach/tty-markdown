# Change log

## [v0.7.0] - unreleased

### Added
* Add converter for br element by @krage
* Add configuration of symbols by @krage
* Add definition list support

### Changed
* Change #new to accept configuration options as keywords
* Display links with both label and optional title by @krage
* Display link without the label when label content is same as link target @krage
* Change hr formatting to be always full width
* Change to remove mailto: from email links for brevity @krage
* Change to update kramdown to support versions >= 1.16 and < 3.0
* Change to update pastel, tty-color & tty-screen dependencies

### Fixed
* Fix break line handling by @krage
* Fix links handling by @krage
* Fix table formatting of empty cells
* Fix content wrapping to account for the current indentation

## [v0.6.0] - 2019-03-30

### Added
* Add markdown xml comments conversion

## [v0.5.1] - 2019-02-07

### Fixed
* Fix spaces around inline code quotes collapses inside list items

## [v0.5.0] - 2018-12-13

### Changed
* Change gemspec to load files directly
* Change to update rouge dependency
* Change to relax constraings on tty-screen and tty-color

## [v0.4.0] - 2018-06-20

## Fixed
* Fix multiline paragraph indentation by Brett(@suwyn)

## [v0.3.0] - 2018-03-17

### Added
* Add :width option to allow setting maximum display width
* Add :colors options for specifying rendering colors capabilities
* Add ability to parse multiline table content

### Changed
* Change color scheme to replace table and links blue with yellow

## Fixed
* Fix issue with multiline blockquote elements raising NoMethodError

## [v0.2.0] - 2018-01-29

### Added
* Add space indented codeblock markdown conversion
* Add markdown math formula conversion
* Add markdown typogrpahic symbols conversion by Tanaka Masaki(@T-a-n-a-k-a-M-a-s-a-k-i)
* Add html entities conversion
* Add warnings about unsupported conversions for completeness

### Changed
* Change gemspec to require Ruby >= 2.0.0

### Fixed
* Fix smart quotes to correctly encode entities

## [v0.1.0] - 2018-01-24

* Initial implementation and release

[v0.7.0]: https://github.com/piotrmurach/tty-markdown/compare/v0.6.0...v0.7.0
[v0.6.0]: https://github.com/piotrmurach/tty-markdown/compare/v0.5.0...v0.6.0
[v0.5.0]: https://github.com/piotrmurach/tty-markdown/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/piotrmurach/tty-markdown/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/piotrmurach/tty-markdown/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/piotrmurach/tty-markdown/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-markdown/compare/v0.1.0
