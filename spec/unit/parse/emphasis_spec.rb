# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    it "converts text marked with a single asterisk" do
      parsed = described_class.parse(
        "Some *easily noticeable* text", color: :always
      )

      expect(parsed).to eq("Some \e[33measily noticeable\e[0m text\n")
    end
  end

  context "when HTML" do
    it "converts text marked with the <em> element" do
      parsed = described_class.parse(
        "Some <em>easily noticeable</em> text", color: :always
      )

      expect(parsed).to eq("Some \e[33measily noticeable\e[0m text\n")
    end

    it "converts text marked with the <i> element" do
      parsed = described_class.parse(
        "Some <i>easily noticeable</i> text", color: :always
      )

      expect(parsed).to eq("Some \e[33measily noticeable\e[0m text\n")
    end
  end
end
