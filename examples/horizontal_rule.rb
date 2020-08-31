# frozen_string_literal: true

require_relative "../lib/tty-markdown"

template = <<-TEXT

## Horizontal Rule

---

TEXT

print TTY::Markdown.parse template
