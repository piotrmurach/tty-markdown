# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when HTML" do
    it "converts the <div> element with text content" do
      parsed = described_class.parse("<div>Some text content</div>")

      expect(parsed).to eq("Some text content")
    end

    it "converts the <div> element with child elements" do
      markdown = "<div><em>Some</em> text <strong>content</strong></div>"
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq("\e[33mSome\e[0m text \e[33;1mcontent\e[0m")
    end

    it "converts the <span> element with text content" do
      parsed = described_class.parse("<span>Some text content</span>")

      expect(parsed).to eq("Some text content\n")
    end

    it "converts the <span> element with child elements" do
      markdown = "<span><em>Some</em> text <strong>content</strong></span>"
      parsed = described_class.parse(markdown, color: :always)

      expect(parsed).to eq("\e[33mSome\e[0m text \e[33;1mcontent\e[0m\n")
    end

    it "converts an empty <span> element" do
      parsed = described_class.parse("<span></span>")

      expect(parsed).to eq("\nHTML element '\"span\"' not supported")
    end
  end
end
