# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "converts two spaces at the end of a line into a line break" do
      parsed = described_class.parse("First line  \nSecond line")

      expect(parsed).to eq("First line\n\nSecond line\n")
    end
  end

  context "when HTML" do
    it "converts the <br> element into a line break" do
      parsed = described_class.parse("First line<br/>Second line")

      expect(parsed).to eq("First line\nSecond line\n")
    end
  end
end
