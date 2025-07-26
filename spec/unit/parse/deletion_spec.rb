# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "doesn't convert text marked with a double tilde" do
      parsed = described_class.parse("Some ~~permanently deleted~~ text")

      expect(parsed).to eq("Some ~~permanently deleted~~ text\n")
    end
  end

  context "when HTML" do
    it "converts an empty <del> element" do
      parsed = described_class.parse("Some <del></del> text.")

      expect(parsed).to eq("Some  text.\n")
    end

    it "converts the <del> element with single-line text" do
      parsed = described_class.parse(
        "Some <del>permanently deleted</del> text.", color: :always
      )

      expect(parsed).to eq("Some \e[31mpermanently deleted\e[0m text.\n")
    end

    it "converts the <del> element with multiline text" do
      parsed = described_class.parse(
        "Some <del>permanently<br>deleted</del> text.", color: :always
      )

      expect(parsed).to eq([
        "Some \e[31mpermanently\e[0m",
        "\e[31mdeleted\e[0m text.\n"
      ].join("\n"))
    end

    it "converts the <del> element with a custom style" do
      markdown = "Some <del>permanently deleted</del> text."
      parsed = described_class.parse(
        markdown, color: :always, theme: {delete: %i[blue bold]}
      )

      expect(parsed).to eq("Some \e[34;1mpermanently deleted\e[0m text.\n")
    end

    it "converts the <del> element after the heading" do
      markdown = <<-TEXT
### Heading

Some <del>permanently deleted</del> text.
      TEXT
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq([
        "    \e[36;1mHeading\e[0m",
        "",
        "    Some \e[31mpermanently deleted\e[0m text.\n"
      ].join("\n"))
    end
  end
end
