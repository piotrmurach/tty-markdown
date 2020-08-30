# frozen_string_literal: true

RSpec.describe TTY::Markdown, "newline" do
  let(:symbols) { TTY::Markdown.symbols }

  it "breaks a line" do
    markdown =<<-TEXT
hello
world
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("hello\nworld\n")
  end

  it "breaks a line with html tag" do
    markdown =<<-TEXT
hello<br/>world
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("hello\nworld\n")
  end
end
