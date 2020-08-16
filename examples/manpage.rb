# frozen_string_literal: true

require_relative "../lib/tty-markdown"

path = File.join(__dir__, "manpage.md")
print TTY::Markdown.parse_file(path, colors: 256)
