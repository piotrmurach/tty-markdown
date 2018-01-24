# frozen_string_literal: true

RSpec.describe TTY::Markdown do
  it "highlights code without language" do
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

  it "highlights code according to language" do
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
end
