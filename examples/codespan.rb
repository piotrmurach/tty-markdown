# frozen_string_literal: true

require_relative "../lib/tty-markdown"

template = <<~MSG

## Codespan

Code like this `foo = []` in line

Another code ```bar = {}``` in line

MSG

print TTY::Markdown.parse template
