# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown = <<-TEXT

## Footnotes

It is not down on any map[^foo]; true places[^bar] never are.

[^foo]: A diagrammatic representation of an area of land or sea.
[^bar]: A particular position, point, or area in space; a location.

## Footnote With Multiline Content

A single line footnote,[^1] and a longer one.[^multiline]

[^1]: A single line footnote.

[^multiline]: A footnote with multiple paragraphs and code.

    Second paragraph of this footnote.

    `{ foo: :bar }`

    Paragraph to finish long description.
TEXT

print TTY::Markdown.parse(markdown)
