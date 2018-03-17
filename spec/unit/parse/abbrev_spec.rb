# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'abbrev' do
  it "abbreviates markdown" do
    markdown =<<-TEXT
*[HTML]: Hyper Text Markup Language
test HTML
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "test HTML\n"
    ].join("\n"))
  end

  it "indents abbreviations correctly" do
    markdown =<<-TEXT
### header
*[HTML]: Hyper Text Markup Language
test HTML
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m",
      "    test HTML\n"
    ].join("\n"))
  end
end
