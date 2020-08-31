# frozen_string_literal: true

require_relative "../lib/tty-markdown"

template = <<-TEXT

## Codeblock

```ruby
class Greeter
  def initialize(name)
    @name = name
  end

  def greet
    puts "Hello \#{@name}"
  end
end
```

TEXT

print TTY::Markdown.parse template
