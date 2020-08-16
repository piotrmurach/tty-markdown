# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown =<<-TEXT

## Unordered List

- First item
- Second item
- Third item
  - Indented item
  - Indented item
- Fourth item

## Ordered List

1. First item
2. Second item
3. Third item
   1. Indented item
   2. Indented item
4. Fourth item

TEXT

print TTY::Markdown.parse(markdown)
