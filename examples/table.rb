# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown =<<-TEXT

## Table With Headers

| First Header | Second Header | Third Header |
|--------------|:-------------:|-------------:|
| Text         | Text          | Text         |
| Text         | Text          | Text         |
| Text         | Text          | Text         |

## Table Without Headers

| Text | Text | Text |
| Text | Text | Text |
| Text | Text | Text |

TEXT

print TTY::Markdown.parse(markdown)
