# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "converts text marked with a double asterisk" do
      parsed = described_class.parse(
        "Some **strongly important** text", color: :always
      )

      expect(parsed).to eq("Some \e[33;1mstrongly important\e[0m text\n")
    end
  end

  context "when HTML" do
    it "converts text marked with the <b> element" do
      parsed = described_class.parse(
        "Some <b>strongly important</b> text", color: :always
      )

      expect(parsed).to eq("Some \e[33;1mstrongly important\e[0m text\n")
    end

    it "converts text marked with the <strong> element" do
      parsed = described_class.parse(
        "Some <strong>strongly important</strong> text", color: :always
      )

      expect(parsed).to eq("Some \e[33;1mstrongly important\e[0m text\n")
    end
  end
end
