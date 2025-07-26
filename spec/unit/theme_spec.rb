# frozen_string_literal: true

RSpec.describe TTY::Markdown::Theme do
  describe ".from" do
    let(:element_to_style) do
      {
        code: %i[yellow],
        comment: %i[bright_black],
        delete: %i[red],
        em: %i[yellow],
        header: %i[cyan bold],
        hr: %i[yellow],
        image: %i[bright_black],
        link: %i[yellow underline],
        list: %i[yellow],
        note: %i[yellow],
        quote: %i[yellow],
        strong: %i[yellow bold],
        table: %i[yellow]
      }
    end
    let(:elements) { element_to_style.keys }
    let(:styles) { element_to_style.values }

    context "when a non-hash" do
      it "raises an error" do
        expect {
          described_class.from(:unknown)
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid theme: :unknown. " \
          "Use the hash with the element name and style."
        )
      end
    end

    context "when a nil" do
      it "defaults to the built-in theme" do
        theme = described_class.from(nil)

        expect(elements.map { |name| theme[name] }).to eq(styles)
      end
    end

    context "when an empty hash" do
      it "defaults to the built-in theme" do
        theme = described_class.from({})

        expect(elements.map { |name| theme[name] }).to eq(styles)
      end
    end

    context "when a non-empty hash" do
      it "overrides the theme element with a style as a string" do
        theme = described_class.from({comment: "blue"})

        expect([theme[:comment], theme[:em], theme[:header]])
          .to eq([%i[blue], %i[yellow], %i[cyan bold]])
      end

      it "overrides the theme element with a style as a symbol" do
        theme = described_class.from({comment: :blue})

        expect([theme[:comment], theme[:em], theme[:header]])
          .to eq([%i[blue], %i[yellow], %i[cyan bold]])
      end

      it "overrides the theme element with a style as strings" do
        theme = described_class.from({comment: %w[blue underline]})

        expect([theme[:comment], theme[:em], theme[:header]])
          .to eq([%i[blue underline], %i[yellow], %i[cyan bold]])
      end

      it "overrides the theme element with a style as symbols" do
        theme = described_class.from({comment: %i[blue underline]})

        expect([theme[:comment], theme[:em], theme[:header]])
          .to eq([%i[blue underline], %i[yellow], %i[cyan bold]])
      end

      it "overrides the theme element with a style as a string and symbol" do
        theme = described_class.from({comment: ["blue", :underline]})

        expect([theme[:comment], theme[:em], theme[:header]])
          .to eq([%i[blue underline], %i[yellow], %i[cyan bold]])
      end

      it "overrides theme elements with styles as a string and symbol" do
        theme = described_class.from({
          comment: "blue",
          header: [:magenta, "underline"]
        })

        expect([theme[:comment], theme[:em], theme[:header]])
          .to eq([%i[blue], %i[yellow], %i[magenta underline]])
      end

      it "raises an error when overriding the theme element name as a string" do
        expect {
          described_class.from({"comment" => :blue})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid theme element name: \"comment\"."
        )
      end

      it "raises an error when overriding an unknown theme element name" do
        expect {
          described_class.from({unknown: :blue})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid theme element name: :unknown."
        )
      end

      it "raises an error when overriding unknown theme element names" do
        expect {
          described_class.from({other: :red, unknown: :blue})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid theme element names: :other, :unknown."
        )
      end
    end
  end

  describe "#[]" do
    subject(:theme) { described_class.from({}) }

    it "fetches styles by element name" do
      expect(theme[:comment]).to eq(%i[bright_black])
    end
  end
end
