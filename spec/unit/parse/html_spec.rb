# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
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
