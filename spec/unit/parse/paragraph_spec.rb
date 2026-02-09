# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "converts paragraphs" do
      markdown = <<-TEXT
The first paragraph of text
that is split into two lines.

The second paragraph of text.
      TEXT
      parsed = described_class.parse(markdown)

      expect(parsed).to eq([
        "The first paragraph of text",
        "that is split into two lines.",
        "",
        "The second paragraph of text.\n"
      ].join("\n"))
    end

    it "converts paragraphs after the heading" do
      markdown = <<-TEXT
### Heading
The first paragraph of text
that is split into two lines.

The second paragraph of text.
      TEXT
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq([
        "    \e[36;1mHeading\e[0m",
        "    The first paragraph of text",
        "    that is split into two lines.",
        "",
        "    The second paragraph of text.\n"
      ].join("\n"))
    end

    it "converts a paragraph after the heading within the allowed width" do
      markdown = <<-TEXT
### Heading

To produce a mighty book, you must choose a mighty theme.
      TEXT
      parsed = described_class.parse(markdown, color: :always, width: 20)

      expect(parsed).to eq([
        "    \e[36;1mHeading\e[0m",
        "",
        "    To produce a ",
        "    mighty book, ",
        "    you must choose ",
        "    a mighty theme.\n"
      ].join("\n"))
    end
  end
end
