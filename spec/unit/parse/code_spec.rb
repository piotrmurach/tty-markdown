# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when inline code" do
    it "converts text marked with a double backtick to colored text" do
      parsed = described_class.parse(
        "Some `inline code` in text", color: :always, mode: 16
      )

      expect(parsed).to eq("Some \e[33minline code\e[0m in text\n")
    end

    it "converts text marked with a double backtick in 256 color mode" do
      parsed = described_class.parse(
        "Some `inline code` in text", color: :always, mode: 256
      )

      expect(parsed).to eq("Some \e[38;5;230minline code\e[39m in text\n")
    end
  end

  context "when code block" do
    it "highlights indented code without a language indicator" do
      markdown = <<-TEXT
    class Greeter
      def say
      end
    end
      TEXT
      parsed = described_class.parse(markdown, color: :always, mode: 16)

      expect(parsed).to eq([
        "\e[33mclass Greeter\e[0m",
        "\e[33m  def say\e[0m",
        "\e[33m  end\e[0m",
        "\e[33mend\e[0m"
      ].join("\n"))
    end

    it "highlights fenced code without a language indicator" do
      markdown = <<-TEXT
```
class Greeter
  def say
  end
end
```
      TEXT
      parsed = described_class.parse(markdown, color: :always, mode: 16)

      expect(parsed).to eq([
        "\e[33mclass Greeter\e[0m",
        "\e[33m  def say\e[0m",
        "\e[33m  end\e[0m",
        "\e[33mend\e[0m"
      ].join("\n"))
    end

    it "highlights fenced code in 256 color mode without a language" do
      markdown = <<-TEXT
```
class Greeter
  def say
  end
end
```
      TEXT
      parsed = described_class.parse(markdown, color: :always, mode: 256)

      expect(parsed).to eq([
        "\e[38;5;230mclass Greeter\e[39m",
        "\e[38;5;230m  def say\e[39m",
        "\e[38;5;230m  end\e[39m",
        "\e[38;5;230mend\e[39m",
        "\e[38;5;230m\e[39m"
      ].join("\n"))
    end

    it "highlights fenced code with a language indicator" do
      markdown = <<-TEXT
```ruby
class Greeter
  def say
  end
end
```
      TEXT
      parsed = described_class.parse(markdown, color: :always, mode: 16)

      expect(parsed).to eq([
        "\e[33mclass Greeter\e[0m",
        "\e[33m  def say\e[0m",
        "\e[33m  end\e[0m",
        "\e[33mend\e[0m"
      ].join("\n"))
    end

    it "highlights fenced code in 256 color mode with a language" do
      markdown = <<-TEXT
```ruby
class Greeter
  def say
  end
end
```
      TEXT
      parsed = described_class.parse(markdown, color: :always, mode: 256)

      expect(parsed).to eq([
        "\e[38;5;221;01mclass\e[39;00m\e[38;5;230m \e[39m",
        "\e[38;5;155;01mGreeter\e[39;00m\e[38;5;230m\e[39m\n",
        "\e[38;5;230m  \e[39m\e[38;5;221;01mdef\e[39;00m\e[38;5;230m \e[39m",
        "\e[38;5;153msay\e[39m\e[38;5;230m\e[39m\n",
        "\e[38;5;230m  \e[39m\e[38;5;221;01mend\e[39;00m\e[38;5;230m\e[39m\n",
        "\e[38;5;230m\e[39m\e[38;5;221;01mend\e[39;00m\e[38;5;230m\e[39m\n",
        "\e[38;5;230m\e[39m"
      ].join)
    end

    it "highlights fenced code with a language indicator and blank lines" do
      markdown = <<-TEXT
```ruby
def say

  puts "saying"

end
```
      TEXT
      parsed = described_class.parse(markdown, color: :always, mode: 16)

      expect(parsed).to eq([
        "\e[33mdef say\e[0m",
        "",
        "\e[33m  puts \"saying\"\e[0m",
        "",
        "\e[33mend\e[0m"
      ].join("\n"))
    end

    it "indents fenced code immediately after the heading" do
      markdown = <<-TEXT
### header
```
class Greeter
  def say
  end
end
```
      TEXT
      parsed = described_class.parse(markdown, color: :always, mode: 16)

      expect(parsed).to eq([
        "    \e[36;1mheader\e[0m",
        "    \e[33mclass Greeter\e[0m",
        "    \e[33m  def say\e[0m",
        "    \e[33m  end\e[0m",
        "    \e[33mend\e[0m"
      ].join("\n"))
    end

    it "indents fenced code after the heading separated by a blank line" do
      markdown = <<-TEXT
### header

```
class Greeter
  def say
  end
end
```
      TEXT
      parsed = described_class.parse(markdown, color: :always, mode: 16)

      expect(parsed).to eq([
        "    \e[36;1mheader\e[0m",
        "",
        "    \e[33mclass Greeter\e[0m",
        "    \e[33m  def say\e[0m",
        "    \e[33m  end\e[0m",
        "    \e[33mend\e[0m"
      ].join("\n"))
    end

    it "wraps fenced code exceeding the maximum width" do
      markdown = <<-TEXT
```
lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText
```
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, mode: 16, width: 50
      )

      expect(parsed).to eq([
        "\e[33mlexer = Rouge::Lexer.find_fancy(lang, code) || \e[0m",
        "\e[33mRouge::Lexers::PlainText\e[0m"
      ].join("\n"))
    end

    it "wraps code exceeding the maximum width preserving indentation" do
      markdown = <<-TEXT
### lexer

```
lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText
```
      TEXT
      parsed = described_class.parse(
        markdown, color: :always, mode: 16, width: 50
      )

      expect(parsed).to eq([
        "    \e[36;1mlexer\e[0m\n",
        "    \e[33mlexer = Rouge::Lexer.find_fancy(lang, code) \e[0m",
        "    \e[33m|| Rouge::Lexers::PlainText\e[0m"
      ].join("\n"))
    end

    it "doesn't highlight fenced code when colors are disabled" do
      markdown = <<-TEXT
```
class Greeter
  def say
  end
end
```
      TEXT
      parsed = described_class.parse(markdown, color: :never)

      expect(parsed).to eq([
        "class Greeter",
        "  def say",
        "  end",
        "end"
      ].join("\n"))
    end
  end
end
