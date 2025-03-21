# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "breaks a line" do
    markdown = <<-TEXT
hello
world
    TEXT
    parsed = described_class.parse(markdown)

    expect(parsed).to eq("hello\nworld\n")
  end

  it "breaks a line with html tag" do
    markdown = <<-TEXT
hello<br/>world
    TEXT
    parsed = described_class.parse(markdown)

    expect(parsed).to eq("hello\nworld\n")
  end
end
