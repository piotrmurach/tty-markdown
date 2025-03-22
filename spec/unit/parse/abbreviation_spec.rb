# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "converts an abbreviation with a description" do
    markdown = <<-TEXT
write HTML page

*[HTML]: Hyper Text Markup Language
    TEXT
    parsed = described_class.parse(markdown)

    expect(parsed).to eq("write HTML(Hyper Text Markup Language) page\n\n")
  end

  it "converts an abbreviation without a description" do
    markdown = <<-TEXT
write HTML page

*[HTML]:
    TEXT
    parsed = described_class.parse(markdown)

    expect(parsed).to eq("write HTML page\n\n")
  end

  it "indents an abbreviation after the heading" do
    markdown = <<-TEXT
### Heading

write HTML page

*[HTML]: Hyper Text Markup Language
    TEXT
    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq([
      "    \e[36;1mHeading\e[0m\n",
      "    write HTML(Hyper Text Markup Language) page\n\n"
    ].join("\n"))
  end
end
