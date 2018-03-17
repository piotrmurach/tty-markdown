# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'header' do
  it "converts top level header" do
    parsed = TTY::Markdown.parse("#Header1")

    expect(parsed).to eq("\e[36;1;4mHeader1\e[0m\n")
  end

  it "converts headers" do
    headers =<<-TEXT
# Header1
header1 content

## Header2
header2 content

### Header3
header3 content
    TEXT
    parsed = TTY::Markdown.parse(headers)

    expect(parsed).to eq([
      "\e[36;1;4mHeader1\e[0m",
      "header1 content",
      "",
      "  \e[36;1mHeader2\e[0m",
      "  header2 content",
      "",
      "    \e[36;1mHeader3\e[0m",
      "    header3 content\n"
    ].join("\n"))
  end
end

