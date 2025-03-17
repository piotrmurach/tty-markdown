# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown = <<-TEXT

## Abbreviation

write HTML page

*[HTML]: Hyper Text Markup Language
TEXT

print TTY::Markdown.parse(markdown)
