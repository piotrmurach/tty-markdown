# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown = <<-TEXT

## Inline link

[TTY Toolkit](https://ttytoolkit.org)

## Inline link with title

[TTY site](https://ttytoolkit.org "TTY Toolkit")

## Inline text matching link

[https://ttytoolkit.org](https://ttytoolkit.org)

## Inline link reference

[TTY Toolkit][1]

## Email link

[Email me](mailto:test@example.com)

[1]: https://ttytoolkit.org

TEXT

print TTY::Markdown.parse(markdown)
