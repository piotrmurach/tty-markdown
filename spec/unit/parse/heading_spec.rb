# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    context "when ATX" do
      it "converts a level 1 heading when color is disabled" do
        parsed = described_class.parse("# Heading", color: :never)

        expect(parsed).to eq("Heading\n")
      end

      it "converts a level 1 heading" do
        parsed = described_class.parse("# Heading", color: :always)

        expect(parsed).to eq("\e[36;1;4mHeading\e[0m\n")
      end

      it "converts a level 2 heading" do
        parsed = described_class.parse("## Heading", color: :always)

        expect(parsed).to eq("  \e[36;1mHeading\e[0m\n")
      end

      it "converts a level 3 heading" do
        parsed = described_class.parse("### Heading", color: :always)

        expect(parsed).to eq("    \e[36;1mHeading\e[0m\n")
      end

      it "converts a level 4 heading" do
        parsed = described_class.parse("#### Heading", color: :always)

        expect(parsed).to eq("      \e[36;1mHeading\e[0m\n")
      end

      it "converts a level 5 heading" do
        parsed = described_class.parse("##### Heading", color: :always)

        expect(parsed).to eq("        \e[36;1mHeading\e[0m\n")
      end

      it "converts a level 6 heading" do
        parsed = described_class.parse("###### Heading", color: :always)

        expect(parsed).to eq("          \e[36;1mHeading\e[0m\n")
      end

      it "converts an invalid level 7 heading" do
        parsed = described_class.parse("####### Heading", color: :always)

        expect(parsed).to eq("          \e[36;1m# Heading\e[0m\n")
      end

      it "converts level 1 to 6 headings" do
        markdown = <<-TEXT
# Heading 1
Text after the level 1 heading.

## Heading 2
Text after the level 2 heading.

### Heading 3
Text after the level 3 heading.

#### Heading 4
Text after the level 4 heading.

##### Heading 5
Text after the level 5 heading.

###### Heading 6
Text after the level 6 heading.
        TEXT
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq([
          "\e[36;1;4mHeading 1\e[0m",
          "Text after the level 1 heading.",
          "",
          "  \e[36;1mHeading 2\e[0m",
          "  Text after the level 2 heading.",
          "",
          "    \e[36;1mHeading 3\e[0m",
          "    Text after the level 3 heading.",
          "",
          "      \e[36;1mHeading 4\e[0m",
          "      Text after the level 4 heading.",
          "",
          "        \e[36;1mHeading 5\e[0m",
          "        Text after the level 5 heading.",
          "",
          "          \e[36;1mHeading 6\e[0m",
          "          Text after the level 6 heading.\n"
        ].join("\n"))
      end

      it "converts a heading with Markdown text" do
        markdown = "## A *Clearly* **Visible** Heading"
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq(
          "  \e[36;1mA \e[33mClearly\e[0m " \
          "\e[33;1mVisible\e[0m\e[36;1m Heading\e[0m\n"
        )
      end

      it "converts level 1 to 6 headings with the custom heading1 style" do
        markdown = <<-TEXT
# Heading 1
Text after the level 1 heading.

## Heading 2
Text after the level 2 heading.

### Heading 3
Text after the level 3 heading.

#### Heading 4
Text after the level 4 heading.

##### Heading 5
Text after the level 5 heading.

###### Heading 6
Text after the level 6 heading.
        TEXT
        parsed = described_class.parse(
          markdown, color: :always, theme: {heading1: %i[blue]}
        )

        expect(parsed).to eq([
          "\e[34mHeading 1\e[0m",
          "Text after the level 1 heading.",
          "",
          "  \e[36;1mHeading 2\e[0m",
          "  Text after the level 2 heading.",
          "",
          "    \e[36;1mHeading 3\e[0m",
          "    Text after the level 3 heading.",
          "",
          "      \e[36;1mHeading 4\e[0m",
          "      Text after the level 4 heading.",
          "",
          "        \e[36;1mHeading 5\e[0m",
          "        Text after the level 5 heading.",
          "",
          "          \e[36;1mHeading 6\e[0m",
          "          Text after the level 6 heading.\n"
        ].join("\n"))
      end

      it "converts level 1 to 6 headings with the custom header style" do
        markdown = <<-TEXT
# Heading 1
Text after the level 1 heading.

## Heading 2
Text after the level 2 heading.

### Heading 3
Text after the level 3 heading.

#### Heading 4
Text after the level 4 heading.

##### Heading 5
Text after the level 5 heading.

###### Heading 6
Text after the level 6 heading.
        TEXT
        parsed = described_class.parse(
          markdown, color: :always, theme: {header: %i[blue]}
        )

        expect(parsed).to eq([
          "\e[36;1;4mHeading 1\e[0m",
          "Text after the level 1 heading.",
          "",
          "  \e[34mHeading 2\e[0m",
          "  Text after the level 2 heading.",
          "",
          "    \e[34mHeading 3\e[0m",
          "    Text after the level 3 heading.",
          "",
          "      \e[34mHeading 4\e[0m",
          "      Text after the level 4 heading.",
          "",
          "        \e[34mHeading 5\e[0m",
          "        Text after the level 5 heading.",
          "",
          "          \e[34mHeading 6\e[0m",
          "          Text after the level 6 heading.\n"
        ].join("\n"))
      end

      it "converts a heading followed by text within the allowed width" do
        markdown = "### Heading\n#{"x" * 21}"
        parsed = described_class.parse(markdown, color: :always, width: 20)

        expect(parsed).to eq([
          "    \e[36;1mHeading\e[0m",
          "    xxxxxxxxxxxxxxxx",
          "    xxxxx\n"
        ].join("\n"))
      end

      it "converts a heading within the allowed width" do
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

    context "when Setext" do
      it "converts a level 1 heading when color is disabled" do
        parsed = described_class.parse("Heading\n=======", color: :never)

        expect(parsed).to eq("Heading\n")
      end

      it "converts a level 1 heading" do
        parsed = described_class.parse("Heading\n=======", color: :always)

        expect(parsed).to eq("\e[36;1;4mHeading\e[0m\n")
      end

      it "converts a level 2 heading" do
        parsed = described_class.parse("Heading\n-------", color: :always)

        expect(parsed).to eq("  \e[36;1mHeading\e[0m\n")
      end

      it "converts level 1 and 2 headings" do
        markdown = <<-TEXT
Heading 1
=========
Text after the level 1 heading.

Heading 2
---------
Text after the level 2 heading.
        TEXT
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq([
          "\e[36;1;4mHeading 1\e[0m",
          "Text after the level 1 heading.",
          "",
          "  \e[36;1mHeading 2\e[0m",
          "  Text after the level 2 heading.\n"
        ].join("\n"))
      end

      it "converts a heading with Markdown text" do
        markdown = "A *Clearly* **Visible** Heading\n---"
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq(
          "  \e[36;1mA \e[33mClearly\e[0m " \
          "\e[33;1mVisible\e[0m\e[36;1m Heading\e[0m\n"
        )
      end
    end
  end
end
