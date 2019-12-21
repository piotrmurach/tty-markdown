# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'newline' do
  let(:symbols) { TTY::Markdown.symbols }

  it "breaks a line" do
    markdown =<<-TEXT
hello  \nworld
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("hello\n\nworld\n")
  end
end
