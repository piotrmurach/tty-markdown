# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    context "with an asterisk" do
      it "converts empty text" do
        markdown = "Some ** text."
        parsed = described_class.parse(markdown)

        expect(parsed).to eq("Some ** text.\n")
      end

      it "converts blank text" do
        markdown = "Some *\t* text."
        parsed = described_class.parse(markdown)

        expect(parsed).to eq("Some *\t* text.\n")
      end

      it "converts text with only the delimiter" do
        markdown = "Some *** text."
        parsed = described_class.parse(markdown)

        expect(parsed).to eq("Some *** text.\n")
      end

      it "converts text with a leading space" do
        markdown = "Some * easily noticeable* text."
        parsed = described_class.parse(markdown)

        expect(parsed).to eq("Some * easily noticeable* text.\n")
      end

      it "converts text" do
        markdown = "Some *easily noticeable* text."
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("Some \e[33measily noticeable\e[0m text.\n")
      end
    end

    context "with an underscore" do
      it "converts empty text" do
        markdown = "Some __ text."
        parsed = described_class.parse(markdown)

        expect(parsed).to eq("Some __ text.\n")
      end

      it "converts blank text" do
        markdown = "Some _\t_ text."
        parsed = described_class.parse(markdown)

        expect(parsed).to eq("Some _\t_ text.\n")
      end

      it "converts text with only the delimiter" do
        markdown = "Some ___ text."
        parsed = described_class.parse(markdown)

        expect(parsed).to eq("Some ___ text.\n")
      end

      it "converts text with a leading space" do
        markdown = "Some _ easily noticeable_ text."
        parsed = described_class.parse(markdown)

        expect(parsed).to eq("Some _ easily noticeable_ text.\n")
      end

      it "converts text" do
        markdown = "Some _easily noticeable_ text."
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("Some \e[33measily noticeable\e[0m text.\n")
      end
    end
  end

  context "when HTML" do
    context "with an <em> element" do
      it "converts text" do
        markdown = "Some <em>easily noticeable</em> text."
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("Some \e[33measily noticeable\e[0m text.\n")
      end
    end

    context "with an <i> element" do
      it "converts text" do
        markdown = "Some <i>easily noticeable</i> text."
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("Some \e[33measily noticeable\e[0m text.\n")
      end
    end
  end
end
