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
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
     "\e[38;5;230m\e[39m",
     "\e[38;5;230mclass Greeter\e[39m",
     "\e[38;5;230m  def say\e[39m",
     "\e[38;5;230m  end\e[39m",
     "\e[38;5;230mend\e[39m",
     "\e[38;5;230m\e[39m\n",
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
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
    "\e[38;5;221;01mclass\e[39;00m\e[38;5;230m \e[39m\e[38;5;155;01mGreeter\e[39;00m\e[38;5;230m\e[39m",
    "\e[38;5;230m  \e[39m\e[38;5;221;01mdef\e[39;00m\e[38;5;230m \e[39m\e[38;5;153msay\e[39m\e[38;5;230m\e[39m",
    "\e[38;5;230m  \e[39m\e[38;5;221;01mend\e[39;00m\e[38;5;230m\e[39m",
    "\e[38;5;230m\e[39m\e[38;5;221;01mend\e[39;00m\e[38;5;230m\e[39m",
    "\e[38;5;230m\e[39m\n"
    ].join("\n"))
  end
end
