# frozen_string_literal: true

RSpec.describe TTY::Markdown, "emphasis" do
  context "when italics emphasis" do
    it "converts asterisks to bold ansi codes" do
      parsed = TTY::Markdown.parse("Some text with *italic* content.",
                                   color: :always)

      expect(parsed).to eq("Some text with \e[33mitalic\e[0m content.\n")
    end
  end

  context "when strikethrough emphasis" do
    it "converts two tildes to ansi codes" do
      parsed = TTY::Markdown.parse("Some text with ~~scratched~~ content.",
                                   color: :always)

      expect(parsed).to eq("Some text with ~~scratched~~ content.\n")
    end
  end

  context "when backticks" do
    it "convertrs backtics to ansi codes" do
      parsed = TTY::Markdown.parse("Some text with `important` content.",
                                   color: :always, mode: 16)

      expect(parsed).to eq("Some text with \e[33mimportant\e[0m content.\n")
    end
  end
end
