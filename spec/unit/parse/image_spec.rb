# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "converts the image syntax with alternative text and source path" do
      markdown = "![TTY logo](images/tty.png)"
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq("\e[90m(TTY logo - images/tty.png)\e[0m\n")
    end

    it "converts the image syntax with the source path only" do
      markdown = "![](images/tty.png)"
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq("\e[90m(images/tty.png)\e[0m\n")
    end
  end

  context "when HTML" do
    it "converts the <img> element with alternative text and source path" do
      markdown = "<img alt=\"TTY logo\" src=\"images/tty.png\" />"
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq("\e[90m(TTY logo - images/tty.png)\e[0m\n")
    end

    it "converts the <img> element with the source path only" do
      markdown = "<img src=\"images/tty.png\" />"
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq("\e[90m(images/tty.png)\e[0m\n")
    end
  end
end
