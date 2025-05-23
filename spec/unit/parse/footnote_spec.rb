# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "converts footnotes to a list at the end of the output" do
      markdown = <<-TEXT
A text with two[^fn1] footnotes[^fn2].

A text without footnotes.

[^fn1]: The first footnote.
[^fn2]: The second footnote.
      TEXT
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq([
        "A text with two\e[33m[1]\e[0m footnotes\e[33m[2]\e[0m.",
        "",
        "A text without footnotes.",
        "",
        "\e[33m1.\e[0m The first footnote.",
        "\e[33m2.\e[0m The second footnote.\n"
      ].join("\n"))
    end

    it "converts footnotes to a unique list" do
      markdown = <<-TEXT
A text with two[^fn1] footnotes[^fn2].

A text with a reused footnote[^fn2].

[^fn1]: The first footnote.
[^fn2]: The second footnote.
      TEXT
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq([
        "A text with two\e[33m[1]\e[0m footnotes\e[33m[2]\e[0m.",
        "",
        "A text with a reused footnote\e[33m[2]\e[0m.",
        "",
        "\e[33m1.\e[0m The first footnote.",
        "\e[33m2.\e[0m The second footnote.\n"
      ].join("\n"))
    end

    it "converts footnotes after the heading to an indented list" do
      markdown = <<-TEXT
### Heading

A text with two[^fn1] footnotes[^fn2].

A text without footnotes.

[^fn1]: The first footnote.
[^fn2]: The second footnote.
      TEXT
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq([
        "    \e[36;1m\Heading\e[0m",
        "",
        "    A text with two\e[33m[1]\e[0m footnotes\e[33m[2]\e[0m.",
        "",
        "    A text without footnotes.",
        "",
        "    \e[33m1.\e[0m The first footnote.",
        "    \e[33m2.\e[0m The second footnote.\n"
      ].join("\n"))
    end
  end
end
