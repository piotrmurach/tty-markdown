# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  let(:markdown) {
    <<-TEXT
# Header

**bold**

```
class Greeter
  def say
  end
end
```
    TEXT
  }

  it "switches off coloring for all elements with never value as a symbol" do
    parsed = described_class.parse(markdown, color: :never)

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

  it "switches off coloring for all elements with never value as a string" do
    parsed = described_class.parse(markdown, color: "never")

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
