# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown =<<-TEXT

## Image

![Code highlight](assets/headers.png)

## Image Source Location

![](assets/headers.png)

TEXT

print TTY::Markdown.parse(markdown)
