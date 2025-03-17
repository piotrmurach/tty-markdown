# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown =<<-TEXT

## Comment

<!-- Single line comment -->

## Comment Block

<!--
A comment that spans more than one line
and explains important information
-->

TEXT

print TTY::Markdown.parse(markdown)
