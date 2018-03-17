# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'link' do
  let(:symbols) { TTY::Markdown.symbols }

  it "converts link" do
    markdown =<<-TEXT
[I'm an inline-style link](https://www.google.com)
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "I#{symbols[:rsquo]}m an inline-style link #{symbols[:arrow]} \e[33;4mhttps://www.google.com\e[0m\n"
    ].join)
  end

  it "converts link with title" do
    markdown =<<-TEXT
[I'm an inline-style link with title](https://www.google.com "Google's Homepage")
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "Google's Homepage #{symbols[:arrow]} \e[33;4mhttps://www.google.com\e[0m\n"
    ].join)
  end
end
