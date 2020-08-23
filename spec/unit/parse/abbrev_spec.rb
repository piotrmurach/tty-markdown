# frozen_string_literal: true

RSpec.describe TTY::Markdown, "abbrev" do
  it "abbreviates markdown" do
    markdown =<<-TEXT
write HTML page

*[HTML]: Hyper Text Markup Language
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("write HTML(Hyper Text Markup Language) page\n\n")
  end

  it "indents abbreviations correctly" do
    markdown =<<-TEXT
### header

write HTML page

*[HTML]: Hyper Text Markup Language
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m\n",
      "    write HTML(Hyper Text Markup Language) page\n\n"
    ].join("\n"))
  end
end
