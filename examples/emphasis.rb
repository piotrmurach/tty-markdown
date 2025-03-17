# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown = <<-TEXT

## Emphasis

This is **bold**

This is *italic*

TEXT

print TTY::Markdown.parse(markdown)
