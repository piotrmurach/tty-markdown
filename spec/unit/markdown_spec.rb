# frozen_string_literal: true

require "tempfile"

RSpec.describe TTY::Markdown do
  subject(:instance) { described_class.new(**options) }

  let(:markdown) do
    <<-TEXT
# First Heading

First *paragraph*.

## Second Heading

Second **paragraph**.

### Third Heading

Third `paragraph`.

***
    TEXT
  end
  let(:options) do
    {
      color: color,
      indent: 4,
      mode: 16,
      symbols: :ascii,
      theme: {em: :blue},
      width: 24
    }
  end

  describe ".parse" do
    context "when color is enabled" do
      let(:color) { :always }

      it "parses Markdown content" do
        parsed = described_class.parse(markdown, **options)

        expect(parsed).to eq([
          "\e[36;1;4mFirst Heading\e[0m",
          "First \e[34mparagraph\e[0m.",
          "    \e[36;1mSecond Heading\e[0m",
          "    Second \e[33;1mparagraph\e[0m.",
          "        \e[36;1mThird Heading\e[0m",
          "        Third \e[33mparagraph\e[0m.",
          "\e[33m*----------------------*\e[0m\n"
        ].join("\n\n"))
      end
    end

    context "when color is disabled" do
      let(:color) { :never }

      it "parses Markdown content" do
        parsed = described_class.parse(markdown, **options)

        expect(parsed).to eq([
          "First Heading",
          "First paragraph.",
          "    Second Heading",
          "    Second paragraph.",
          "        Third Heading",
          "        Third paragraph.",
          "*----------------------*\n"
        ].join("\n\n"))
      end
    end
  end

  describe ".parse_file" do
    context "when color is enabled" do
      let(:color) { :always }

      it "parses a Markdown file" do
        Tempfile.open("test.md") do |file|
          file.write(markdown)
          file.rewind

          parsed = described_class.parse_file(file, **options)

          expect(parsed).to eq([
            "\e[36;1;4mFirst Heading\e[0m",
            "First \e[34mparagraph\e[0m.",
            "    \e[36;1mSecond Heading\e[0m",
            "    Second \e[33;1mparagraph\e[0m.",
            "        \e[36;1mThird Heading\e[0m",
            "        Third \e[33mparagraph\e[0m.",
            "\e[33m*----------------------*\e[0m\n"
          ].join("\n\n"))
        end
      end
    end

    context "when color is disabled" do
      let(:color) { :never }

      it "parses a Markdown file" do
        Tempfile.open("test.md") do |file|
          file.write(markdown)
          file.rewind

          parsed = described_class.parse_file(file, **options)

          expect(parsed).to eq([
            "First Heading",
            "First paragraph.",
            "    Second Heading",
            "    Second paragraph.",
            "        Third Heading",
            "        Third paragraph.",
            "*----------------------*\n"
          ].join("\n\n"))
        end
      end
    end
  end

  describe "#initialize" do
    context "when color is invalid" do
      let(:color) { :unknown }

      it "raises an error" do
        expect { instance }.to raise_error(
          TTY::Markdown::Error,
          "invalid color: :unknown. Use the :always, :auto or :never value."
        )
      end
    end
  end

  describe "#parse" do
    context "when color is enabled" do
      let(:color) { :always }

      it "parses Markdown content" do
        parsed = instance.parse(markdown)

        expect(parsed).to eq([
          "\e[36;1;4mFirst Heading\e[0m",
          "First \e[34mparagraph\e[0m.",
          "    \e[36;1mSecond Heading\e[0m",
          "    Second \e[33;1mparagraph\e[0m.",
          "        \e[36;1mThird Heading\e[0m",
          "        Third \e[33mparagraph\e[0m.",
          "\e[33m*----------------------*\e[0m\n"
        ].join("\n\n"))
      end
    end

    context "when color is disabled" do
      let(:color) { :never }

      it "parses Markdown content" do
        parsed = instance.parse(markdown)

        expect(parsed).to eq([
          "First Heading",
          "First paragraph.",
          "    Second Heading",
          "    Second paragraph.",
          "        Third Heading",
          "        Third paragraph.",
          "*----------------------*\n"
        ].join("\n\n"))
      end
    end
  end

  describe "#parse_file" do
    context "when color is enabled" do
      let(:color) { :always }

      it "parses a Markdown file" do
        Tempfile.open("test.md") do |file|
          file.write(markdown)
          file.rewind

          parsed = instance.parse_file(file)

          expect(parsed).to eq([
            "\e[36;1;4mFirst Heading\e[0m",
            "First \e[34mparagraph\e[0m.",
            "    \e[36;1mSecond Heading\e[0m",
            "    Second \e[33;1mparagraph\e[0m.",
            "        \e[36;1mThird Heading\e[0m",
            "        Third \e[33mparagraph\e[0m.",
            "\e[33m*----------------------*\e[0m\n"
          ].join("\n\n"))
        end
      end
    end

    context "when color is disabled" do
      let(:color) { :never }

      it "parses a Markdown file" do
        Tempfile.open("test.md") do |file|
          file.write(markdown)
          file.rewind

          parsed = instance.parse_file(file)

          expect(parsed).to eq([
            "First Heading",
            "First paragraph.",
            "    Second Heading",
            "    Second paragraph.",
            "        Third Heading",
            "        Third paragraph.",
            "*----------------------*\n"
          ].join("\n\n"))
        end
      end
    end
  end
end
