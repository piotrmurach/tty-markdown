# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown = <<-TEXT
# Header 1

I try all things, I achieve what I can.

## Header 2

I try all things, I achieve what I can.

### Header 3

I try all things, I achieve what I can.

#### Header 4

I try all things, I achieve what I can.

##### Header 5

I try all things, I achieve what I can.

###### Header 6

I try all things, I achieve what I can.
TEXT

print TTY::Markdown.parse(markdown)
