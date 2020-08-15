# frozen_string_literal: true

require_relative "../lib/tty-markdown"

path = File.join(__dir__, "man.md")
print TTY::Markdown.parse_file(path, colors: 256)
