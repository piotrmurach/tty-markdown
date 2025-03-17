# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown = <<-TEXT

## Math formula inline

Wave form: $$ nλ = dsinθ $$

## Math formula block

Wave form:

$$ nλ = dsinθ $$

TEXT

print TTY::Markdown.parse(markdown)
