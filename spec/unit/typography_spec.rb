# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "converts header with typographic symbols" do
    markdown = <<-TEXT
--- << typographic >> ... symbols --
    TEXT
    parsed = described_class.parse(markdown, symbols: :unicode)

    expect(parsed).to eq("\u2014 « typographic » … symbols -\n")
  end

  it "converts smart quotes to utf-8 chars" do
    markdown = "To \"extract\" `script.rb`'s..."
    parsed = described_class.parse(
      markdown, color: :always, mode: 16, symbols: :unicode
    )

    expect(parsed).to eq("To “extract” \e[33mscript.rb\e[0m’s…\n")
  end
end
