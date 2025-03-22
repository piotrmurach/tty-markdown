# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "converts the <div> element with text content" do
    parsed = described_class.parse("<div>Some text content</div>")

    expect(parsed).to eq("Some text content")
  end

  it "converts the <div> element with child elements" do
    markdown = "<div><em>Some</em> text <strong>content</strong></div>"
    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq("\e[33mSome\e[0m text \e[33;1mcontent\e[0m")
  end

  it "converts the <span> element with text content" do
    parsed = described_class.parse("<span>Some text content</span>")

    expect(parsed).to eq("Some text content\n")
  end

  it "converts the <span> element with child elements" do
    markdown = "<span><em>Some</em> text <strong>content</strong></span>"
    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq("\e[33mSome\e[0m text \e[33;1mcontent\e[0m\n")
  end

  it "supports del html element" do
    markdown = <<-TEXT
<del>done</del> made a mistake
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("d\u0336o\u0336n\u0336e\u0336 made a mistake\n")
  end

  it "supports del html element without context" do
    markdown = <<-TEXT
### Header

<del>done</del>
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "    \e[36;1mHeader\e[0m\n",
      "    d\u0336o\u0336n\u0336e\u0336\n"
    ].join("\n"))
  end

  it "supports a html element" do
    markdown = <<-TEXT
<a href="https://ttytoolkit.org">TTY Toolkit</a>
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("TTY Toolkit » \e[33;4mhttps://ttytoolkit.org\e[0m\n")
  end

  it "supports b/strong html element" do
    markdown = <<-TEXT
<strong>bold</strong>
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\e[33;1mbold\e[0m\n")
  end

  it "supports em/i html element" do
    markdown = <<-TEXT
<em>emphasised</em>
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\e[33memphasised\e[0m\n")
  end
end
