# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'codeblock' do
  it "highlights a fenced code without language" do
    markdown =<<-TEXT
```
class Greeter
  def say
  end
end
```
    TEXT
    parsed = TTY::Markdown.parse(markdown, colors: 16)
    expect(parsed).to eq([
     "\e[33mclass Greeter\e[0m",
     "\e[33m  def say\e[0m",
     "\e[33m  end\e[0m",
     "\e[33mend\e[0m\n"
    ].join("\n"))
  end

  it "highlights code without language" do
    markdown =<<-TEXT
    class Greeter
      def say
      end
    end
    TEXT
    parsed = TTY::Markdown.parse(markdown, colors: 16)
    expect(parsed).to eq([
     "\e[33mclass Greeter\e[0m",
     "\e[33m  def say\e[0m",
     "\e[33m  end\e[0m",
     "\e[33mend\e[0m"
    ].join("\n"))
  end

  it "highlights fenced code according to language" do
    markdown =<<-TEXT
```ruby
class Greeter
  def say
  end
end
```
    TEXT
    parsed = TTY::Markdown.parse(markdown, colors: 16)
    expect(parsed).to eq([
     "\e[33mclass Greeter\e[0m",
     "\e[33m  def say\e[0m",
     "\e[33m  end\e[0m",
     "\e[33mend\e[0m\n"
    ].join("\n"))
  end

  it "indents immediate code correctly" do
    markdown =<<-TEXT
### header
```
class Greeter
  def say
  end
end
```
    TEXT
    parsed = TTY::Markdown.parse(markdown, colors: 16)
    expect(parsed).to eq([
     "    \e[36;1mheader\e[0m",
     "    \e[33mclass Greeter\e[0m",
     "    \e[33m  def say\e[0m",
     "    \e[33m  end\e[0m",
     "    \e[33mend\e[0m\n"
    ].join("\n"))
  end

  it "indents code after blank correctly" do
    markdown =<<-TEXT
### header

```
class Greeter
  def say
  end
end
```
    TEXT
    parsed = TTY::Markdown.parse(markdown, colors: 16)
    expect(parsed).to eq([
     "    \e[36;1mheader\e[0m",
     "",
     "    \e[33mclass Greeter\e[0m",
     "    \e[33m  def say\e[0m",
     "    \e[33m  end\e[0m",
     "    \e[33mend\e[0m\n"
    ].join("\n"))
  end

  it "wraps code exceeding set width" do
    markdown =<<-TEXT
```
lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText
```
    TEXT
    parsed = TTY::Markdown.parse(markdown, width: 50, colors: 16)

    expected_output =
      "\e[33mlexer = Rouge::Lexer.find_fancy(lang, code) || \e[0m\n" +
      "\e[33mRouge::Lexers::PlainText\e[0m\n"

    expect(parsed).to eq(expected_output)
  end

  it "wraps code exceeding set width preserving indentation" do
    markdown =<<-TEXT
### lexer

```
lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText
```
    TEXT
    parsed = TTY::Markdown.parse(markdown, width: 50, colors: 16)

    expected_output =
      "    \e[36;1mlexer\e[0m\n\n" +
      "    \e[33mlexer = Rouge::Lexer.find_fancy(lang, code) || \e[0m\n" +
      "    \e[33mRouge::Lexers::PlainText\e[0m\n"

    expect(parsed).to eq(expected_output)
  end
end
