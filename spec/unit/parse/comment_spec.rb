# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'comment' do
  it "converts xml type comment" do
    markdown =<<-TEXT
text before
<!-- TODO: this is a comment -->
text after
    TEXT

    parsed = TTY::Markdown.parse(markdown)

    expect(parsed).to eq([
      "text before\n",
      "<!-- TODO: this is a comment -->\n",
      "text after\n"
    ].join("\n"))
  end
end
