# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'paragraph' do
  it "converts multiline paragraphs" do
    markdown =<<-TEXT
This is a first paragraph
that spans two lines.

And this is a next one.
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "This is a first paragraph",
      "that spans two lines.",
      "",
      "And this is a next one.\n"
    ].join("\n"))
  end

  it "converts multiline pragraphs within header section" do

    markdown =<<-TEXT
### header
This is a first paragraph
that spans two lines.

And this is a next one.
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m",
      "    This is a first paragraph",
      "    that spans two lines.",
      "",
      "    And this is a next one.\n"
    ].join("\n"))
  end
end
