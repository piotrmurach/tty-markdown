# frozen_string_literal: true

RSpec.describe TTY::Markdown, "color" do
  it "switches off coloring for all elements" do
    markdown =<<-TEXT
# Header

**bold**

```
class Greeter
  def say
  end
end
```
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :never)

    expect(parsed).to eq([
      "Header",
      "",
      "bold",
      "",
      "class Greeter",
      "  def say",
      "  end",
      "end"
    ].join("\n"))
  end
end
