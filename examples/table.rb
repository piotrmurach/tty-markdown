# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown =<<-TEXT

## Table with Header and Footer

| First Header | Second Header | Third Header |
|--------------|:-------------:|-------------:|
| Text         | Text          | Text         |
| Text         | Text          | Text         |
| Text         | Text          | Text         |
|==============|===============|==============|
| First Footer | Second Footer | Third Footer |

## Table with Body only

| Text | Text | Text |
| Text | Text | Text |
| Text | Text | Text |

TEXT

print TTY::Markdown.parse(markdown, width: 36)
