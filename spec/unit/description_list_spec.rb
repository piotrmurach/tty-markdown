# frozen_string_literal: true

RSpec.describe TTY::Markdown, "definition list" do
  it "supports definition list conversion" do
    markdown =<<-TEXT
Before para
Item1
: description1

Item2
: description2

After para
    TEXT

    parsed = described_class.parse(markdown)

    expect(parsed).to eq([
      "Before para",
      "Item1",
      "  description1",
      "",
      "Item2",
      "  description2",
      "",
      "After para\n"
    ].join("\n"))
  end

  it "indents definition list within header section" do
    markdown =<<-TEXT
### Header3

Item1
: description1

Item2
: description2

After para
    TEXT

    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq([
      "    \e[36;1mHeader3\e[0m\n",
      "    Item1",
      "      description1",
      "",
      "    Item2",
      "      description2",
      "",
      "    After para\n"
    ].join("\n"))
  end

  it "allows headers in description" do
    markdown =<<-TEXT
List + header
: # Header 1
    TEXT

    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq([
      "List + header",
      "  \e[36;1;4mHeader 1\e[0m\n"
    ].join("\n"))
  end
end
