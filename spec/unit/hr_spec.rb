# frozen_string_literal: true

RSpec.describe TTY::Markdown, "horizontal rule" do
  let(:symbols) { TTY::Markdown::SYMBOLS }

  it "draws a horizontal rule" do
    markdown =<<-TEXT
---
    TEXT
    parsed = TTY::Markdown.parse(markdown, width: 10, symbols: :unicode)
    expect(parsed).to eq("\e[33m#{symbols[:diamond]}#{symbols[:line]*8}#{symbols[:diamond]}\e[0m\n")
  end

  it "draws a horizontal rule within header indentation" do
    markdown =<<-TEXT
### header
---
    TEXT
    parsed = TTY::Markdown.parse(markdown, width: 20, symbols: :unicode)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m\n",
      "\e[33m#{symbols[:diamond]}#{symbols[:line]*18}#{symbols[:diamond]}\e[0m\n"
    ].join)
  end
end
