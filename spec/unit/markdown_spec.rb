# frozen_string_literal: true

require "tempfile"

RSpec.describe TTY::Markdown, ".parse_file" do
  context "when color is enabled" do
    it "parses a Markdown file" do
      markdown = <<-TEXT
# First Heading

First *paragraph*

## Second Heading

Second **paragraph**

### Third Heading

Third `paragraph`
      TEXT
      Tempfile.open("test.md") do |file|
        file.write(markdown)
        file.rewind

        parsed = described_class.parse_file(file, color: :always, mode: 256)

        expect(parsed).to eq([
          "\e[36;1;4mFirst Heading\e[0m",
          "First \e[33mparagraph\e[0m",
          "  \e[36;1mSecond Heading\e[0m",
          "  Second \e[33;1mparagraph\e[0m",
          "    \e[36;1mThird Heading\e[0m",
          "    Third \e[38;5;230mparagraph\e[39m\n"
        ].join("\n\n"))
      end
    end
  end

  context "when color is disabled" do
    it "parses a Markdown file" do
      markdown = <<-TEXT
# First Heading

First *paragraph*

## Second Heading

Second **paragraph**

### Third Heading

Third `paragraph`
      TEXT
      Tempfile.open("test.md") do |file|
        file.write(markdown)
        file.rewind

        parsed = described_class.parse_file(file, color: :never)

        expect(parsed).to eq([
          "First Heading",
          "First paragraph",
          "  Second Heading",
          "  Second paragraph",
          "    Third Heading",
          "    Third paragraph\n"
        ].join("\n\n"))
      end
    end
  end
end
