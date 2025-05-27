# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when HTML" do
    it "converts a single-line comment within a paragraph" do
      markdown = <<-TEXT
Text before.
<!-- A single-line comment. -->
Text after.
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, symbols: :unicode
      )

      expect(parsed).to eq([
        "Text before.",
        "\e[90m# A single-line comment. \e[0m",
        "Text after.\n"
      ].join("\n"))
    end

    it "converts a multiline comment within a paragraph" do
      markdown = <<-TEXT
Text before.
<!--
A multiline comment
that spans two lines.
-->
Text after.
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, symbols: :unicode
      )

      expect(parsed).to eq([
        "Text before.",
        "\e[90m# A multiline comment\e[0m",
        "\e[90m# that spans two lines.\e[0m",
        "Text after.\n"
      ].join("\n"))
    end

    it "converts a single-line comment within an indented paragraph" do
      markdown = <<-TEXT
### Heading

Text before.
<!-- A single-line comment. -->
Text after.
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, symbols: :unicode
      )

      expect(parsed).to eq([
        "    \e[36;1mHeading\e[0m",
        "",
        "    Text before.",
        "    \e[90m# A single-line comment. \e[0m",
        "    Text after.\n"
      ].join("\n"))
    end

    it "converts a multiline comment within an indented paragraph" do
      markdown = <<-TEXT
### Heading

Text before.
<!--
A multiline comment
that spans two lines.
-->
Text after.
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, symbols: :unicode
      )

      expect(parsed).to eq([
        "    \e[36;1mHeading\e[0m",
        "",
        "    Text before.",
        "    \e[90m# A multiline comment\e[0m",
        "    \e[90m# that spans two lines.\e[0m",
        "    Text after.\n"
      ].join("\n"))
    end

    it "converts a single-line comment after the heading" do
      markdown = <<-TEXT
### Heading

<!-- A single-line comment. -->
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, symbols: :unicode
      )

      expect(parsed).to eq([
        "    \e[36;1mHeading\e[0m",
        "",
        "    \e[90m# A single-line comment. \e[0m\n"
      ].join("\n"))
    end

    it "converts a multiline comment after the heading" do
      markdown = <<-TEXT
### Heading

<!--
A multiline comment
that spans two lines.
-->
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, symbols: :unicode
      )

      expect(parsed).to eq([
        "    \e[36;1mHeading\e[0m",
        "",
        "    \e[90m# A multiline comment\e[0m",
        "    \e[90m# that spans two lines.\e[0m\n"
      ].join("\n"))
    end
  end
end
