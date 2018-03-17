# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'horizontal rule' do
  let(:symbols) { TTY::Markdown.symbols }

  it "draws a horizontal rule" do
    markdown =<<-TEXT
---
    TEXT
    parsed = TTY::Markdown.parse(markdown, width: 10)
    expect(parsed).to eq("\e[33m#{symbols[:diamond]}#{symbols[:line]*8}#{symbols[:diamond]}\e[0m\n")
  end

  it "draws a horizontal rule within header indentation" do
    markdown =<<-TEXT
### header
---
    TEXT
    parsed = TTY::Markdown.parse(markdown, width: 20)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m\n",
      "    \e[33m#{symbols[:diamond]}#{symbols[:line]*10}#{symbols[:diamond]}\e[0m\n"
    ].join)
  end
end
