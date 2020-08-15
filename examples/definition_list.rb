# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown =<<-TEXT
def + header
: ## I try all things, I achieve what I can.

def + paragraphs
: I know not all that may be coming,
: but be it what it will, I'll go to it laughing.

def + list
: * Item 1
  * Item 2
  * Item 3
TEXT

print TTY::Markdown.parse(markdown)
