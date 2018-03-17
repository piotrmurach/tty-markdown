# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'emphasis' do
  context 'when strong emphasis' do
    it "converts asterisks to bold ansi codes" do
      parsed = TTY::Markdown.parse("Some text with **bold** content.")

      expect(parsed).to eq("Some text with \e[33;1mbold\e[0m content.\n")
    end
  end

  context 'when italics emphasis' do
    it "converts asterisks to bold ansi codes" do
      parsed = TTY::Markdown.parse("Some text with *italic* content.")

      expect(parsed).to eq("Some text with \e[33mitalic\e[0m content.\n")
    end
  end

  context 'when strikethrough emphasis' do
    it "converts two tildes to ansi codes" do
      parsed = TTY::Markdown.parse("Some text with ~~scratched~~ content.")

      expect(parsed).to eq("Some text with ~~scratched~~ content.\n")
    end
  end

  context "when backticks" do
    it "convertrs backtics to ansi codes" do
      parsed = TTY::Markdown.parse("Some text with `important` content.", colors: 16)

      expect(parsed).to eq("Some text with \e[33mimportant\e[0m content.\n")
    end
  end
end
