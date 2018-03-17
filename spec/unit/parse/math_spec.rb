# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'math' do
  it "converts math formulae" do
    markdown =<<-TEXT
$$5+5$$
    TEXT
    parsed = TTY::Markdown.parse(markdown, colors: 16)
    expect(parsed).to eq("\e[33m5+5\e[0m\n")
  end

  it "indents maths formulae correctly" do
    markdown =<<-TEXT
### header

$$5+5$$
    TEXT
    parsed = TTY::Markdown.parse(markdown, colors: 16)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m",
      "",
      "    \e[33m5+5\e[0m\n"
    ].join("\n"))
  end

  it "indents immediate maths formulae correctly" do
    markdown =<<-TEXT
### header
$$5+5$$
    TEXT
    parsed = TTY::Markdown.parse(markdown, colors: 16)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m",
      "    \e[33m5+5\e[0m\n"
    ].join("\n"))
  end
end
