# frozen_string_literal: true

RSpec.describe TTY::Markdown, "math" do
  it "converts math formula as block" do
    markdown =<<-TEXT
math
$$5+5$$
formula
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, mode: 16)
    expect(parsed).to eq("math\n\e[33m5+5\e[0m\nformula\n")
  end

  it "converts math formula surrounded by blank" do
    markdown =<<-TEXT
$$5+5$$
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, mode: 16)
    expect(parsed).to eq("\e[33m5+5\e[0m\n")
  end

  it "converts text with inline math" do
    markdown =<<-TEXT
math $$5+5$$ formula
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, mode: 16)
    expect(parsed).to eq("math \e[33m5+5\e[0m formula\n")
  end

  it "indents maths formulae correctly" do
    markdown =<<-TEXT
### header

$$5+5$$
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, mode: 16)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m",
      "",
      "    \e[33m5+5\e[0m\n"
    ].join("\n"))
  end

  it "indents immediate maths formulae correctly" do
    markdown =<<-TEXT
### header
$$5+5$$
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, mode: 16)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m",
      "    \e[33m5+5\e[0m\n"
    ].join("\n"))
  end
end
