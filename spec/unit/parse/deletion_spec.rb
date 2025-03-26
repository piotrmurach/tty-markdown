# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "doesn't convert text marked with a double tilde" do
      parsed = described_class.parse("Some ~~permanently deleted~~ text")

      expect(parsed).to eq("Some ~~permanently deleted~~ text\n")
    end
  end

  context "when HTML" do
    it "converts text marked with the <del> element" do
      parsed = described_class.parse(
        "Some <del>deleted</del> text", symbols: :unicode
      )

      expect(parsed).to eq(
        "Some d\u0336e\u0336l\u0336e\u0336t\u0336e\u0336d\u0336 text\n"
      )
    end

    it "indents text marked with the <del> element after the heading" do
      markdown = <<-TEXT
### Heading

<del>deleted</del> text
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, symbols: :unicode
      )

      expect(parsed).to eq([
        "    \e[36;1mHeading\e[0m\n",
        "    d\u0336e\u0336l\u0336e\u0336t\u0336e\u0336d\u0336 text\n"
      ].join("\n"))
    end
  end
end
