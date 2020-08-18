# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown =<<-TEXT

## Blockquote

> Human madness is oftentimes a cunning and most feline thing. When you think it fled, it may have but become transfigured into some still subtler form.

TEXT

print TTY::Markdown.parse(markdown, width: 80)
