# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "converts a paragraph" do
      markdown = "A paragraph of text."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq("A paragraph of text.\n")
    end

    it "converts a multiline paragraph" do
      markdown = "A paragraph of text\nthat is split into two lines."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq(
        "A paragraph of text\nthat is split into two lines.\n"
      )
    end

    it "converts a paragraph with three leading spaces" do
      markdown = "   A paragraph of text."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq("A paragraph of text.\n")
    end

    it "converts a paragraph with a leading space and a tab" do
      markdown = " \tA paragraph of text."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq(" \tA paragraph of text.\n")
    end

    it "converts a multiline paragraph with three leading spaces" do
      markdown = "   A paragraph of text\n   that is split into two lines."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq(
        "A paragraph of text\n   that is split into two lines.\n"
      )
    end

    it "converts a multiline paragraph with a leading space and a tab" do
      markdown = " \tA paragraph of text\n \tthat is split into two lines."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq(
        " \tA paragraph of text\n \tthat is split into two lines.\n"
      )
    end

    it "converts a paragraph with spaces and tabs" do
      markdown = "A   paragraph \tof\ttext."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq("A   paragraph \tof\ttext.\n")
    end

    it "converts a multiline paragraph with spaces and tabs" do
      markdown = "A   paragraph \tof\ttext\nthat\t is \tsplit into  two\tlines."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq(
        "A   paragraph \tof\ttext\nthat\t is \tsplit into  two\tlines.\n"
      )
    end

    it "converts a paragraph with three trailing spaces" do
      markdown = "A paragraph of text.   "
      parsed = described_class.parse(markdown)

      expect(parsed).to eq("A paragraph of text.\n")
    end

    it "converts a paragraph with a trailing space and a tab" do
      markdown = "A paragraph of text. \t"
      parsed = described_class.parse(markdown)

      expect(parsed).to eq("A paragraph of text.\n")
    end

    it "converts a multiline paragraph with three trailing spaces" do
      markdown = "A paragraph of text   \nthat is split into two lines.   "
      parsed = described_class.parse(markdown)

      expect(parsed).to eq(
        "A paragraph of text \n\nthat is split into two lines.\n"
      )
    end

    it "converts a multiline paragraph with a trailing space and a tab" do
      markdown = "A paragraph of text \t\nthat is split into two lines. \t"
      parsed = described_class.parse(markdown)

      expect(parsed).to eq(
        "A paragraph of text \t\nthat is split into two lines.\n"
      )
    end

    it "converts paragraphs separated by empty lines" do
      markdown = "The first paragraph.\n\n\n\nThe second paragraph."
      parsed = described_class.parse(markdown)

      expect(parsed).to eq("The first paragraph.\n\nThe second paragraph.\n")
    end

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
