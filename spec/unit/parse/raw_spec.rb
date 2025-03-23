# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when HTML" do
    it "doesn't convert the <script> element with raw content" do
      parsed = described_class.parse("<script>const raw = true;</script>")

      expect(parsed).to eq(
        "Raw content is not supported\nRaw content is not supported"
      )
    end

    it "doesn't convert the <style> element with raw content" do
      parsed = described_class.parse("<style>p {color: green;}</style>")

      expect(parsed).to eq(
        "Raw content is not supported\nRaw content is not supported"
      )
    end
  end
end
