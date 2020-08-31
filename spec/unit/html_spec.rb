# frozen_string_literal: true

RSpec.describe TTY::Markdown, "html" do
  let(:symbols) { TTY::Markdown::SYMBOLS }
  let(:del) { symbols[:delete] }

  it "supports del html element" do
    markdown =<<-TEXT
<del>done</del> made a mistake
    TEXT
    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)
    expect(parsed).to eq("d#{del}o#{del}n#{del}e#{del} made a mistake\n")
  end

  it "supports del html element without context" do
    markdown =<<-TEXT
### Header

<del>done</del>
    TEXT
    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)
    expect(parsed).to eq([
      "    \e[36;1mHeader\e[0m\n",
      "    d#{del}o#{del}n#{del}e#{del}\n"
    ].join("\n"))
  end

  it "supports a html element" do
    markdown =<<-TEXT
<a href="https://ttytoolkit.org">TTY Toolkit</a>
    TEXT
    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)
    expect(parsed).to eq("TTY Toolkit #{symbols[:arrow]} \e[33;4mhttps://ttytoolkit.org\e[0m\n")
  end

  it "supports b/strong html element" do
    markdown =<<-TEXT
<strong>bold</strong>
    TEXT
    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)
    expect(parsed).to eq("\e[33;1mbold\e[0m\n")
  end

  it "supports em/i html element" do
    markdown =<<-TEXT
<em>emphasised</em>
    TEXT
    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)
    expect(parsed).to eq("\e[33memphasised\e[0m\n")
  end
end
