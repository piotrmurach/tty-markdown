# frozen_string_literal: true

require_relative "../lib/tty-markdown"

path = File.join(__dir__, "demo.md")
puts TTY::Markdown.parse_file(path, colors: 256, width: 80)
