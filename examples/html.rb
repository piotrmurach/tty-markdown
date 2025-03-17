# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown = <<-TEXT

## Deleted

<del>done</del> made a mistake

## Newline

content<br>

## Image

<img width="130" src="https://github.com/piotrmurach/tty/raw/master/images/tty.png" alt="tty logo" />

TEXT

print TTY::Markdown.parse(markdown)
