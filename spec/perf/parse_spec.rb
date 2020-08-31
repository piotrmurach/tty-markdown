# frozen_string_literal: true

require "rspec-benchmark"

RSpec.describe TTY::Markdown do
  include RSpec::Benchmark::Matchers

  def markdown_doc
    <<-TEXT
# Header

## Header 2

- Item 1
  - Item 2
    - Item 3

**Item 1**
: This is the description for Item 1

> Blockquote

```ruby
foo = {}
```

| Foo |  Bar | Baz |
|-----|:----:|----:|
| aaa | bbb  | ccc |

***
    TEXT
  end

  it "transforms markdown to terminal output slower than Kramdown HTML" do
    expect {
      TTY::Markdown.parse(markdown_doc)
    }.to perform_slower_than {
      Kramdown::Document.new(markdown_doc).to_html
    }.at_most(3.6).times
  end
end
