# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    context "when color is disabled" do
      context "when inline code" do
        it "converts code marked with a double backtick" do
          markdown = "Some `puts 5 + 5` code."
          parsed = described_class.parse(markdown, color: :never)

          expect(parsed).to eq("Some puts 5 + 5 code.\n")
        end
      end

      context "when code block" do
        it "converts fenced code" do
          markdown = <<-TEXT
```
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(markdown, color: :never)

          expect(parsed).to eq([
            "class Greeter",
            "  def say",
            "    \"hello\"",
            "  end",
            "end\n"
          ].join("\n"))
        end
      end
    end

    context "when 16-color mode" do
      let(:mode) { 16 }

      context "when inline code" do
        it "converts code marked with a double backtick" do
          markdown = "Some `puts 5 + 5` code."
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq("Some \e[33mputs 5 + 5\e[0m code.\n")
        end

        it "converts code with a custom style" do
          markdown = "Some `puts 5 + 5` code."
          parsed = described_class.parse(
            markdown, color: :always, mode: mode, theme: {code: %i[blue bold]}
          )

          expect(parsed).to eq("Some \e[34;1mputs 5 + 5\e[0m code.\n")
        end
      end

      context "when code block" do
        it "converts indented code without a language indicator" do
          markdown = <<-TEXT
    class Greeter
      def say
        "hello"
      end
    end
          TEXT
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq([
            "\e[33mclass Greeter\e[0m",
            "\e[33m  def say\e[0m",
            "\e[33m    \"hello\"\e[0m",
            "\e[33m  end\e[0m",
            "\e[33mend\e[0m\n"
          ].join("\n"))
        end

        it "converts fenced code without a language indicator" do
          markdown = <<-TEXT
```
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq([
            "\e[33mclass Greeter\e[0m",
            "\e[33m  def say\e[0m",
            "\e[33m    \"hello\"\e[0m",
            "\e[33m  end\e[0m",
            "\e[33mend\e[0m\n"
          ].join("\n"))
        end

        it "converts fenced code with a custom style" do
          markdown = <<-TEXT
```
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(
            markdown, color: :always, mode: mode, theme: {code: %i[blue bold]}
          )

          expect(parsed).to eq([
            "\e[34;1mclass Greeter\e[0m",
            "\e[34;1m  def say\e[0m",
            "\e[34;1m    \"hello\"\e[0m",
            "\e[34;1m  end\e[0m",
            "\e[34;1mend\e[0m\n"
          ].join("\n"))
        end

        it "converts fenced code with a language indicator" do
          markdown = <<-TEXT
```ruby
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq([
            "\e[33mclass Greeter\e[0m",
            "\e[33m  def say\e[0m",
            "\e[33m    \"hello\"\e[0m",
            "\e[33m  end\e[0m",
            "\e[33mend\e[0m\n"
          ].join("\n"))
        end

        it "converts fenced code with a language indicator and custom style" do
          markdown = <<-TEXT
```ruby
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(
            markdown, color: :always, mode: mode, theme: {code: %i[blue bold]}
          )

          expect(parsed).to eq([
            "\e[34;1mclass Greeter\e[0m",
            "\e[34;1m  def say\e[0m",
            "\e[34;1m    \"hello\"\e[0m",
            "\e[34;1m  end\e[0m",
            "\e[34;1mend\e[0m\n"
          ].join("\n"))
        end

        it "converts fenced code with a language indicator and blank lines" do
          markdown = <<-TEXT
```ruby
class Greeter

  def say

    "hello"

  end

end
```
          TEXT
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq([
            "\e[33mclass Greeter\e[0m",
            "",
            "\e[33m  def say\e[0m",
            "",
            "\e[33m    \"hello\"\e[0m",
            "",
            "\e[33m  end\e[0m",
            "",
            "\e[33mend\e[0m\n"
          ].join("\n"))
        end

        it "converts fenced code immediately after the heading" do
          markdown = <<-TEXT
### Heading
```
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq([
            "    \e[36;1mHeading\e[0m",
            "    \e[33mclass Greeter\e[0m",
            "    \e[33m  def say\e[0m",
            "    \e[33m    \"hello\"\e[0m",
            "    \e[33m  end\e[0m",
            "    \e[33mend\e[0m\n"
          ].join("\n"))
        end

        it "converts fenced code after the heading separated by a blank line" do
          markdown = <<-TEXT
### Heading

```
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq([
            "    \e[36;1mHeading\e[0m",
            "",
            "    \e[33mclass Greeter\e[0m",
            "    \e[33m  def say\e[0m",
            "    \e[33m    \"hello\"\e[0m",
            "    \e[33m  end\e[0m",
            "    \e[33mend\e[0m\n"
          ].join("\n"))
        end

        it "converts fenced code exceeding the maximum width" do
          markdown = <<-TEXT
```
puts (1..100).map { |n| n + 5 }.join(", ")
```
          TEXT
          parsed = described_class.parse(
            markdown, color: :always, mode: mode, width: 15
          )

          expect(parsed).to eq([
            "\e[33mputs \e[0m",
            "\e[33m(1..100).map { \e[0m",
            "\e[33m|n| n + 5 \e[0m",
            "\e[33m}.join(\", \")\e[0m\n"
          ].join("\n"))
        end

        it "converts code exceeding the maximum width after the heading" do
          markdown = <<-TEXT
### Heading

```
puts (1..100).map { |n| n + 5 }.join(", ")
```
          TEXT
          parsed = described_class.parse(
            markdown, color: :always, mode: mode, width: 15
          )

          expect(parsed).to eq([
            "    \e[36;1mHeading\e[0m",
            "",
            "    \e[33mputs \e[0m",
            "    \e[33m(1..100\e[0m",
            "    \e[33m).map { \e[0m",
            "    \e[33m|n| n + 5 \e[0m",
            "    \e[33m}.join(\", \e[0m",
            "    \e[33m\")\e[0m\n"
          ].join("\n"))
        end
      end
    end

    context "when 256-color mode" do
      let(:mode) { 256 }

      context "when inline code" do
        it "converts code marked with a double backtick" do
          markdown = "Some `puts 5 + 5` code."
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq("Some \e[38;5;230mputs 5 + 5\e[39m code.\n")
        end
      end

      context "when code block" do
        it "converts fenced code without a language indicator" do
          markdown = <<-TEXT
```
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq([
            "\e[38;5;230mclass Greeter\e[39m",
            "\e[38;5;230m  def say\e[39m",
            "\e[38;5;230m    \"hello\"\e[39m",
            "\e[38;5;230m  end\e[39m",
            "\e[38;5;230mend\e[39m",
            "\e[38;5;230m\e[39m\n"
          ].join("\n"))
        end

        it "converts fenced code with a language indicator" do
          markdown = <<-TEXT
```ruby
class Greeter
  def say
    "hello"
  end
end
```
          TEXT
          parsed = described_class.parse(markdown, color: :always, mode: mode)

          expect(parsed).to eq([
            "\e[38;5;221;01mclass\e[39;00m\e[38;5;230m \e[39m" \
            "\e[38;5;155;01mGreeter\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mdef\e[39;00m" \
            "\e[38;5;230m \e[39m\e[38;5;153msay\e[39m" \
            "\e[38;5;230m\e[39m",
            "\e[38;5;230m    \e[39m\e[38;5;229;01m\"hello\"\e[39;00m" \
            "\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mend\e[39;00m" \
            "\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\e[38;5;221;01mend\e[39;00m" \
            "\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\n"
          ].join("\n"))
        end
      end
    end
  end
end
