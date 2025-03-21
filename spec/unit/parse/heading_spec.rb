# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "converts top level header" do
    parsed = described_class.parse("Header1\n======", color: :always)

    expect(parsed).to eq("\e[36;1;4mHeader1\e[0m\n")
  end

  it "disables top level header coloring" do
    parsed = described_class.parse("Header1\n======", color: :never)

    expect(parsed).to eq("Header1\n")
  end

  it "converts headers" do
    headers = <<-TEXT
# Header1
header1 content

## Header2
header2 content

### Header3
header3 content
    TEXT
    parsed = described_class.parse(headers, color: :always)

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
    parsed = described_class.parse(
      "### Header3\n#{"x" * 21}", color: :always, width: 20
    )

    expect(parsed).to eq([
      "    \e[36;1mHeader3\e[0m",
      "    xxxxxxxxxxxxxxxx",
      "    xxxxx\n"
    ].join("\n"))
  end

  it "indents long header within the specified width" do
    header = "### It is not down on any map; true places never are."
    parsed = described_class.parse(header, color: :always, width: 20)

    expect(parsed).to eq([
      "    \e[36;1mIt is not down \e[0m",
      "    \e[36;1mon any map; \e[0m",
      "    \e[36;1mtrue places \e[0m",
      "    \e[36;1mnever are.\e[0m\n"
    ].join("\n"))
  end
end
