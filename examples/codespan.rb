# frozen_string_literal: true

require_relative "../lib/tty-markdown"

template = <<-TEXT

## Codespan

Code like this `foo = []` in line

Another code ```bar = {}``` in line

TEXT

print TTY::Markdown.parse template
