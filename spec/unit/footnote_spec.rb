# frozen_string_literal: true

RSpec.describe TTY::Markdown, "footnote" do
  it "shows footnote references at the end of document" do
    markdown =<<-TEXT
Some text about Item1[^foo] and Item2[^bar]

[^foo]: A first footnote
[^bar]: A second footnote
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always)
    expect(parsed).to eq([
      "Some text about Item1\e[33m[1]\e[0m and Item2\e[33m[2]\e[0m",
      "",
      "\e[33m1.\e[0m A first footnote",
      "\e[33m2.\e[0m A second footnote\n",
    ].join("\n"))
  end

  it "reuses existing footnote references" do
    markdown =<<-TEXT
Some text about Item1[^foo] and Item2[^bar]

Another line about Item1[^foo]

[^foo]: A first footnote
[^bar]: A second footnote
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always)
    expect(parsed).to eq([
      "Some text about Item1\e[33m[1]\e[0m and Item2\e[33m[2]\e[0m",
      "",
      "Another line about Item1\e[33m[1]\e[0m",
      "",
      "\e[33m1.\e[0m A first footnote",
      "\e[33m2.\e[0m A second footnote\n",
    ].join("\n"))
  end

  it "indents footnotes" do
    markdown =<<-TEXT
### Header3

Some text about Item1[^foo] and Item2[^bar]

[^foo]: A first footnote
[^bar]: A second footnote
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always)
    expect(parsed).to eq([
      "    \e[36;1m\Header3\e[0m",
      "",
      "    Some text about Item1\e[33m[1]\e[0m and Item2\e[33m[2]\e[0m",
      "",
      "    \e[33m1.\e[0m A first footnote",
      "    \e[33m2.\e[0m A second footnote\n",
    ].join("\n"))
  end
end
