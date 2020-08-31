# frozen_string_literal: true

RSpec.describe TTY::Markdown, "html" do
  let(:del) { TTY::Markdown::SYMBOLS[:delete] }

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
end
