# frozen_string_literal: true

RSpec.describe TTY::Markdown, "comment" do
  let(:symbols) { TTY::Markdown::SYMBOLS }

  it "converts xml comment within paragraph" do
    markdown =<<-TEXT
text before
<!-- TODO: this is a comment -->
text after
    TEXT

    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)

    expect(parsed).to eq([
      "text before",
      "\e[90m#{symbols[:hash]} TODO: this is a comment \e[0m",
      "text after\n"
    ].join("\n"))
  end

  it "converts multiline xml comment within paragraph" do
    markdown =<<-TEXT
text before
<!--
TODO: this is a comment
that spans two lines
-->
text after
    TEXT

    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)

    expect(parsed).to eq([
      "text before",
      "\e[90m#{symbols[:hash]} TODO: this is a comment\e[0m",
      "\e[90m#{symbols[:hash]} that spans two lines\e[0m",
      "text after\n"
    ].join("\n"))
  end

  it "converts inline xml comment with indent inside paragraph" do
    markdown =<<-TEXT
### Header

text before
<!-- TODO: this is a comment -->
text after
    TEXT

    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)

    expect(parsed).to eq([
      "    \e[36;1mHeader\e[0m",
      "",
      "    text before",
      "    \e[90m#{symbols[:hash]} TODO: this is a comment \e[0m",
      "    text after\n"
    ].join("\n"))
  end

  it "converts multiline xml comment with indent inside paragraph" do
    markdown =<<-TEXT
### Header

text before
<!--
TODO: this is a comment
that spans two lines
-->
text after
    TEXT

    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)

    expect(parsed).to eq([
      "    \e[36;1mHeader\e[0m",
      "",
      "    text before",
      "    \e[90m#{symbols[:hash]} TODO: this is a comment\e[0m",
      "    \e[90m#{symbols[:hash]} that spans two lines\e[0m",
      "    text after\n"
    ].join("\n"))
  end

  it "converts xml comment with indent without any context" do
    markdown =<<-TEXT
### Header

<!-- TODO: this is a comment -->
    TEXT

    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)

    expect(parsed).to eq([
      "    \e[36;1mHeader\e[0m",
      "",
      "    \e[90m#{symbols[:hash]} TODO: this is a comment \e[0m\n",
    ].join("\n"))
  end

  it "converts multiline xml comment with indent without any context" do
    markdown =<<-TEXT
### Header

<!--
TODO: this is a comment
that spans two lines
-->
    TEXT

    parsed = TTY::Markdown.parse(markdown, symbols: :unicode)

    expect(parsed).to eq([
      "    \e[36;1mHeader\e[0m",
      "",
      "    \e[90m#{symbols[:hash]} TODO: this is a comment\e[0m",
      "    \e[90m#{symbols[:hash]} that spans two lines\e[0m\n",
    ].join("\n"))
  end
end
