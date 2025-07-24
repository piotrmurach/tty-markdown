# frozen_string_literal: true

RSpec.describe TTY::Markdown::Highlighter do
  subject(:highlighter) do
    described_class.new(pastel, mode: mode, styles: %i[blue])
  end

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
      let(:pastel) { Pastel.new(enabled: false) }

      it "doesn't highlight code" do
        highlighter = described_class.new(pastel)
        highlighted = highlighter.highlight(code)

        expect(highlighted).to eq(code)
      end
    end

    context "when 16-color mode" do
      let(:color) { pastel.blue.detach }
      let(:mode) { 16 }

      it "doesn't highlight code without styles" do
        highlighter = described_class.new(pastel, mode: mode)
        highlighted = highlighter.highlight(code)

        expect(highlighted).to eq(code)
      end

      it "highlights code with a custom style" do
        highlighted = highlighter.highlight(code)

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end

      it "highlights code with the nil language" do
        highlighted = highlighter.highlight(code, nil)

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end

      it "highlights code with the guess language" do
        highlighted = highlighter.highlight(code, "guess")

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end

      it "highlights code with the ruby language" do
        highlighted = highlighter.highlight(code, "ruby")

        expect(highlighted).to eq([
          "\e[34mclass Greeter\e[0m",
          "\e[34m  def say\e[0m",
          "\e[34m    \"hello\"\e[0m",
          "\e[34m  end\e[0m",
          "\e[34mend\e[0m"
        ].join("\n"))
      end

      it "highlights code with the unknown language" do
        highlighted = highlighter.highlight(code, "unknown")

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
          highlighted = highlighter.highlight(code, nil)

          expect(highlighted).to eq([
            "\e[38;5;230mclass Greeter\e[39m",
            "\e[38;5;230m  def say\e[39m",
            "\e[38;5;230m    \"hello\"\e[39m",
            "\e[38;5;230m  end\e[39m",
            "\e[38;5;230mend\e[39m"
          ].join("\n"))
        end

        it "highlights code as generic with the guess language" do
          highlighted = highlighter.highlight(code, "guess")

          expect(highlighted).to eq([
            "\e[38;5;230mclass Greeter\e[39m",
            "\e[38;5;230m  def say\e[39m",
            "\e[38;5;230m    \"hello\"\e[39m",
            "\e[38;5;230m  end\e[39m",
            "\e[38;5;230mend\e[39m"
          ].join("\n"))
        end

        it "highlights code as Ruby with the ruby language" do
          highlighted = highlighter.highlight(code, "ruby")

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
          highlighted = highlighter.highlight(code, "unknown")

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
          highlighted = highlighter.highlight("#{metadata}\n#{code}", nil)

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
          highlighted = highlighter.highlight("#{metadata}\n#{code}", "guess")

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
          highlighted = highlighter.highlight("#{metadata}\n#{code}", "ruby")

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
          highlighted = highlighter.highlight("#{metadata}\n#{code}", "unknown")

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

    context "when truecolor mode" do
      let(:mode) { 2**24 }

      context "without Ruby metadata" do
        it "highlights code as generic with the nil language" do
          highlighted = highlighter.highlight(code, nil)

          expect(highlighted).to eq([
            "\e[38;2;250;246;228mclass Greeter\e[39m",
            "\e[38;2;250;246;228m  def say\e[39m",
            "\e[38;2;250;246;228m    \"hello\"\e[39m",
            "\e[38;2;250;246;228m  end\e[39m",
            "\e[38;2;250;246;228mend\e[39m"
          ].join("\n"))
        end

        it "highlights code as generic with the guess language" do
          highlighted = highlighter.highlight(code, "guess")

          expect(highlighted).to eq([
            "\e[38;2;250;246;228mclass Greeter\e[39m",
            "\e[38;2;250;246;228m  def say\e[39m",
            "\e[38;2;250;246;228m    \"hello\"\e[39m",
            "\e[38;2;250;246;228m  end\e[39m",
            "\e[38;2;250;246;228mend\e[39m"
          ].join("\n"))
        end

        it "highlights code as Ruby with the ruby language" do
          highlighted = highlighter.highlight(code, "ruby")

          expect(highlighted).to eq([
            "\e[38;2;246;221;98m\e[1mclass\e[39;00m" \
            "\e[38;2;250;246;228m \e[39m" \
            "\e[38;2;178;253;109m\e[1mGreeter\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m  \e[39m" \
            "\e[38;2;246;221;98m\e[1mdef\e[39;00m" \
            "\e[38;2;250;246;228m \e[39m" \
            "\e[38;2;168;225;254msay\e[39m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m    \e[39m" \
            "\e[38;2;255;240;166m\e[1m\"hello\"\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m  \e[39m" \
            "\e[38;2;246;221;98m\e[1mend\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m\e[39m" \
            "\e[38;2;246;221;98m\e[1mend\e[39;00m"
          ].join("\n"))
        end

        it "highlights code as generic with the unknown language" do
          highlighted = highlighter.highlight(code, "unknown")

          expect(highlighted).to eq([
            "\e[38;2;250;246;228mclass Greeter\e[39m",
            "\e[38;2;250;246;228m  def say\e[39m",
            "\e[38;2;250;246;228m    \"hello\"\e[39m",
            "\e[38;2;250;246;228m  end\e[39m",
            "\e[38;2;250;246;228mend\e[39m"
          ].join("\n"))
        end
      end

      context "with Ruby metadata" do
        let(:metadata) { "#!/usr/bin/env ruby" }

        it "highlights code as Ruby with the nil language" do
          highlighted = highlighter.highlight("#{metadata}\n#{code}", nil)

          expect(highlighted).to eq([
            "\e[38;2;108;139;159m\e[1m#!/usr/bin/env ruby\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m\e[39m" \
            "\e[38;2;246;221;98m\e[1mclass\e[39;00m" \
            "\e[38;2;250;246;228m \e[39m" \
            "\e[38;2;178;253;109m\e[1mGreeter\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m  \e[39m" \
            "\e[38;2;246;221;98m\e[1mdef\e[39;00m" \
            "\e[38;2;250;246;228m \e[39m" \
            "\e[38;2;168;225;254msay\e[39m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m    \e[39m" \
            "\e[38;2;255;240;166m\e[1m\"hello\"\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m  \e[39m" \
            "\e[38;2;246;221;98m\e[1mend\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m\e[39m" \
            "\e[38;2;246;221;98m\e[1mend\e[39;00m"
          ].join("\n"))
        end

        it "highlights code as Ruby with the guess language" do
          highlighted = highlighter.highlight("#{metadata}\n#{code}", "guess")

          expect(highlighted).to eq([
            "\e[38;2;108;139;159m\e[1m#!/usr/bin/env ruby\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m\e[39m" \
            "\e[38;2;246;221;98m\e[1mclass\e[39;00m" \
            "\e[38;2;250;246;228m \e[39m" \
            "\e[38;2;178;253;109m\e[1mGreeter\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m  \e[39m" \
            "\e[38;2;246;221;98m\e[1mdef\e[39;00m" \
            "\e[38;2;250;246;228m \e[39m" \
            "\e[38;2;168;225;254msay\e[39m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m    \e[39m" \
            "\e[38;2;255;240;166m\e[1m\"hello\"\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m  \e[39m" \
            "\e[38;2;246;221;98m\e[1mend\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m\e[39m" \
            "\e[38;2;246;221;98m\e[1mend\e[39;00m"
          ].join("\n"))
        end

        it "highlights code as Ruby with the ruby language" do
          highlighted = highlighter.highlight("#{metadata}\n#{code}", "ruby")

          expect(highlighted).to eq([
            "\e[38;2;108;139;159m\e[1m#!/usr/bin/env ruby\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m\e[39m" \
            "\e[38;2;246;221;98m\e[1mclass\e[39;00m" \
            "\e[38;2;250;246;228m \e[39m" \
            "\e[38;2;178;253;109m\e[1mGreeter\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m  \e[39m" \
            "\e[38;2;246;221;98m\e[1mdef\e[39;00m" \
            "\e[38;2;250;246;228m \e[39m" \
            "\e[38;2;168;225;254msay\e[39m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m    \e[39m" \
            "\e[38;2;255;240;166m\e[1m\"hello\"\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m  \e[39m" \
            "\e[38;2;246;221;98m\e[1mend\e[39;00m" \
            "\e[38;2;250;246;228m\e[39m",
            "\e[38;2;250;246;228m\e[39m" \
            "\e[38;2;246;221;98m\e[1mend\e[39;00m"
          ].join("\n"))
        end

        it "highlights code as generic with the unknown language" do
          highlighted = highlighter.highlight("#{metadata}\n#{code}", "unknown")

          expect(highlighted).to eq([
            "\e[38;2;250;246;228m#!/usr/bin/env ruby\e[39m",
            "\e[38;2;250;246;228mclass Greeter\e[39m",
            "\e[38;2;250;246;228m  def say\e[39m",
            "\e[38;2;250;246;228m    \"hello\"\e[39m",
            "\e[38;2;250;246;228m  end\e[39m",
            "\e[38;2;250;246;228mend\e[39m"
          ].join("\n"))
        end
      end
    end
  end
end
