# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'link' do
  let(:symbols) { TTY::Markdown.symbols }

  it "displays link with label" do
    markdown =<<-TEXT
[I'm an inline-style link](https://www.google.com)
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("I#{symbols[:rsquo]}m an inline-style link #{symbols[:arrow]} \e[33;4mhttps://www.google.com\e[0m\n")
  end

  it "displays link with label and title" do
    markdown =<<-TEXT
[I'm an inline-style link with title](https://www.google.com "Google's Homepage")
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("I#{symbols[:rsquo]}m an inline-style link with title #{symbols[:arrow]}(Google's Homepage) \e[33;4mhttps://www.google.com\e[0m\n")
  end

  it "displays nothing when label is empty" do
    markdown = "[](https://example.com)"
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("\n")
  end

  it "displays nothing when label is empty but title is present" do
    markdown = "[](https://example.com \"Title\")"
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("\n")
  end

  it "displays nothing when label is just whitespace" do
    markdown = "[\n\t ](https://example.com)"
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("\n")
  end

  it "displays link without displaying label when label matches link target" do
    markdown = "[https://example.com](https://example.com)"
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("\e[33;4mhttps://example.com\e[0m\n")
  end

  it "displays typical autolinks without displaying label" do
    markdown = "<https://example.com>"
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("\e[33;4mhttps://example.com\e[0m\n")
  end
end
