# frozen_string_literal: true

RSpec.describe TTY::Markdown::SyntaxHighliter do
  let(:code) do
    <<-TEXT.chomp
class Greeter
  def say
    "hello"
  end
end
    TEXT
  end
  let(:pastel) { Pastel.new(enabled: true) }

  describe ".highlight" do
    context "when disabled" do
      it "doesn't highlight code" do
        highlighted = described_class.highlight(code, enabled: false)

        expect(highlighted).to eq(code)
      end
    end

    context "when 16-color mode" do
      let(:color) { pastel.blue.detach }
      let(:mode) { 16 }

      it "doesn't highlight code without color" do
        highlighted = described_class.highlight(code, mode: mode)

        expect(highlighted).to eq(code)
      end

      it "highlights code with a custom color" do
        highlighted = described_class.highlight(
          code, color: color, mode: mode
        )

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end

      it "highlights code with the nil language" do
        highlighted = described_class.highlight(
          code, color: color, lang: nil, mode: mode
        )

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end

      it "highlights code with the guess language" do
        highlighted = described_class.highlight(
          code, color: color, lang: "guess", mode: mode
        )

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end

      it "highlights code with the ruby language" do
        highlighted = described_class.highlight(
          code, color: color, lang: "ruby", mode: mode
        )

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end

      it "highlights code with the unknown language" do
        highlighted = described_class.highlight(
          code, color: color, lang: "unknown", mode: mode
        )

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end
    end

    context "when 256-color mode" do
      let(:mode) { 256 }

      context "without Ruby metadata" do
        it "highlights code as generic with the nil language" do
          highlighted = described_class.highlight(
            code, lang: nil, mode: mode
          )

          expect(highlighted).to eq([
            "\e[38;5;230mclass Greeter\e[39m",
            "\e[38;5;230m  def say\e[39m",
            "\e[38;5;230m    \"hello\"\e[39m",
            "\e[38;5;230m  end\e[39m",
            "\e[38;5;230mend\e[39m"
          ].join("\n"))
        end

        it "highlights code as generic with the guess language" do
          highlighted = described_class.highlight(
            code, lang: "guess", mode: mode
          )

          expect(highlighted).to eq([
            "\e[38;5;230mclass Greeter\e[39m",
            "\e[38;5;230m  def say\e[39m",
            "\e[38;5;230m    \"hello\"\e[39m",
            "\e[38;5;230m  end\e[39m",
            "\e[38;5;230mend\e[39m"
          ].join("\n"))
        end

        it "highlights code as Ruby with the ruby language" do
          highlighted = described_class.highlight(
            code, lang: "ruby", mode: mode
          )

          expect(highlighted).to eq([
            "\e[38;5;221;01mclass\e[39;00m\e[38;5;230m \e[39m" \
            "\e[38;5;155;01mGreeter\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mdef\e[39;00m\e[38;5;230m " \
            "\e[39m\e[38;5;153msay\e[39m\e[38;5;230m\e[39m",
            "\e[38;5;230m    \e[39m" \
            "\e[38;5;229;01m\"hello\"\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mend\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\e[38;5;221;01mend\e[39;00m"
          ].join("\n"))
        end

        it "highlights code as generic with the unknown language" do
          highlighted = described_class.highlight(
            code, lang: "unknown", mode: mode
          )

          expect(highlighted).to eq([
            "\e[38;5;230mclass Greeter\e[39m",
            "\e[38;5;230m  def say\e[39m",
            "\e[38;5;230m    \"hello\"\e[39m",
            "\e[38;5;230m  end\e[39m",
            "\e[38;5;230mend\e[39m"
          ].join("\n"))
        end
      end

      context "with Ruby metadata" do
        let(:metadata) { "#!/usr/bin/env ruby" }

        it "highlights code as Ruby with the nil language" do
          highlighted = described_class.highlight(
            "#{metadata}\n#{code}", lang: nil, mode: mode
          )

          expect(highlighted).to eq([
            "\e[38;5;67;04m#!/usr/bin/env ruby\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\e[38;5;221;01mclass\e[39;00m\e[38;5;230m " \
            "\e[39m\e[38;5;155;01mGreeter\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mdef\e[39;00m\e[38;5;230m " \
            "\e[39m\e[38;5;153msay\e[39m\e[38;5;230m\e[39m",
            "\e[38;5;230m    \e[39m" \
            "\e[38;5;229;01m\"hello\"\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mend\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\e[38;5;221;01mend\e[39;00m"
          ].join("\n"))
        end

        it "highlights code as Ruby with the guess language" do
          highlighted = described_class.highlight(
            "#{metadata}\n#{code}", lang: "guess", mode: mode
          )

          expect(highlighted).to eq([
            "\e[38;5;67;04m#!/usr/bin/env ruby\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\e[38;5;221;01mclass\e[39;00m\e[38;5;230m " \
            "\e[39m\e[38;5;155;01mGreeter\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mdef\e[39;00m\e[38;5;230m " \
            "\e[39m\e[38;5;153msay\e[39m\e[38;5;230m\e[39m",
            "\e[38;5;230m    \e[39m" \
            "\e[38;5;229;01m\"hello\"\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mend\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\e[38;5;221;01mend\e[39;00m"
          ].join("\n"))
        end

        it "highlights code as Ruby with the ruby language" do
          highlighted = described_class.highlight(
            "#{metadata}\n#{code}", lang: "ruby", mode: mode
          )

          expect(highlighted).to eq([
            "\e[38;5;67;04m#!/usr/bin/env ruby\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\e[38;5;221;01mclass\e[39;00m\e[38;5;230m " \
            "\e[39m\e[38;5;155;01mGreeter\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mdef\e[39;00m\e[38;5;230m " \
            "\e[39m\e[38;5;153msay\e[39m\e[38;5;230m\e[39m",
            "\e[38;5;230m    \e[39m" \
            "\e[38;5;229;01m\"hello\"\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m  \e[39m\e[38;5;221;01mend\e[39;00m\e[38;5;230m\e[39m",
            "\e[38;5;230m\e[39m\e[38;5;221;01mend\e[39;00m"
          ].join("\n"))
        end

        it "highlights code as generic with the unknown language" do
          highlighted = described_class.highlight(
            "#{metadata}\n#{code}", lang: "unknown", mode: mode
          )

          expect(highlighted).to eq([
            "\e[38;5;230m#!/usr/bin/env ruby\e[39m",
            "\e[38;5;230mclass Greeter\e[39m",
            "\e[38;5;230m  def say\e[39m",
            "\e[38;5;230m    \"hello\"\e[39m",
            "\e[38;5;230m  end\e[39m",
            "\e[38;5;230mend\e[39m"
          ].join("\n"))
        end
      end
    end
  end
end
