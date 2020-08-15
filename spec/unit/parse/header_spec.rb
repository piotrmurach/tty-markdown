# frozen_string_literal: true

RSpec.describe TTY::Markdown, "header" do
  it "converts top level header" do
    parsed = TTY::Markdown.parse("Header1\n======")

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

  it "indents within the specified width" do
    twenty21 = "x" * 21
    parsed = TTY::Markdown.parse("### Header3\n" + twenty21, width: 20)

    expected_output = [
      "    \e[36;1mHeader3\e[0m",
      "    xxxxxxxxxxxxxxxx",
      "    xxxxx\n"
    ].join("\n")

    expect(parsed).to eq(expected_output)
  end
end

