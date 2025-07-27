# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "converts the level 1 heading when color is disabled" do
      parsed = described_class.parse("Heading1\n========", color: :never)

      expect(parsed).to eq("Heading1\n")
    end

    it "converts the level 1 heading" do
      parsed = described_class.parse("Heading1\n========", color: :always)

      expect(parsed).to eq("\e[36;1;4mHeading1\e[0m\n")
    end

    it "converts level 1, 2 and 3 headings" do
      markdown = <<-TEXT
# Heading1
Content after the level 1 heading.

## Heading2
Content after the level 2 heading.

### Heading3
Content after the level 3 heading.
      TEXT
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq([
        "\e[36;1;4mHeading1\e[0m",
        "Content after the level 1 heading.",
        "",
        "  \e[36;1mHeading2\e[0m",
        "  Content after the level 2 heading.",
        "",
        "    \e[36;1mHeading3\e[0m",
        "    Content after the level 3 heading.\n"
      ].join("\n"))
    end

    it "converts level 1, 2 and 3 headings with the custom heading1 style" do
      markdown = <<-TEXT
# Heading1
Content after the level 1 heading.

## Heading2
Content after the level 2 heading.

### Heading3
Content after the level 3 heading.
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, theme: {heading1: :blue}
      )

      expect(parsed).to eq([
        "\e[34mHeading1\e[0m",
        "Content after the level 1 heading.",
        "",
        "  \e[36;1mHeading2\e[0m",
        "  Content after the level 2 heading.",
        "",
        "    \e[36;1mHeading3\e[0m",
        "    Content after the level 3 heading.\n"
      ].join("\n"))
    end

    it "converts level 1, 2 and 3 headings with the custom header style" do
      markdown = <<-TEXT
# Heading1
Content after the level 1 heading.

## Heading2
Content after the level 2 heading.

### Heading3
Content after the level 3 heading.
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, theme: {header: :blue}
      )

      expect(parsed).to eq([
        "\e[36;1;4mHeading1\e[0m",
        "Content after the level 1 heading.",
        "",
        "  \e[34mHeading2\e[0m",
        "  Content after the level 2 heading.",
        "",
        "    \e[34mHeading3\e[0m",
        "    Content after the level 3 heading.\n"
      ].join("\n"))
    end

    it "converts the heading followed by content within the allowed width" do
      markdown = "### Heading3\n#{"x" * 21}"
      parsed = described_class.parse(markdown, color: :always, width: 20)

      expect(parsed).to eq([
        "    \e[36;1mHeading3\e[0m",
        "    xxxxxxxxxxxxxxxx",
        "    xxxxx\n"
      ].join("\n"))
    end

    it "converts the long heading within the allowed width" do
      markdown = "### It is not down on any map; true places never are."
      parsed = described_class.parse(markdown, color: :always, width: 20)

      expect(parsed).to eq([
        "    \e[36;1mIt is not down \e[0m",
        "    \e[36;1mon any map; \e[0m",
        "    \e[36;1mtrue places \e[0m",
        "    \e[36;1mnever are.\e[0m\n"
      ].join("\n"))
    end
  end
end
