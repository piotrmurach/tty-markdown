# frozen_string_literal: true

require_relative "../lib/tty-markdown"

template = <<~MSG

## Horizontal Rule

---

MSG

print TTY::Markdown.parse template
