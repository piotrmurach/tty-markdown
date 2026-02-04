# frozen_string_literal: true

RSpec.describe TTY::Markdown::Decorator do
  subject(:decorator) { described_class.new(pastel, theme) }

  let(:pastel) { Pastel.new(enabled: true) }
  let(:theme) { TTY::Markdown::Theme.from({em: [], strong: %i[blue bold]}) }
  let(:text) { "To produce a mighty book,\nyou must choose a mighty theme." }

  describe "#enabled?" do
    context "when the pastel is enabled" do
      let(:pastel) { Pastel.new(enabled: true) }

      it "enables text decoration" do
        expect(decorator.enabled?).to be(true)
      end
    end

    context "when the pastel is disabled" do
      let(:pastel) { Pastel.new(enabled: false) }

      it "disables text decoration" do
        expect(decorator.enabled?).to be(false)
      end
    end
  end

  describe "#decorate" do
    it "decorates text with unstyled theme element" do
      expect(decorator.decorate(text, :em)).to eq(text)
    end

    it "decorates text with theme element styles" do
      expect(decorator.decorate(text, :strong)).to eq([
        "\e[34;1mTo produce a mighty book,",
        "you must choose a mighty theme.\e[0m"
      ].join("\n"))
    end
  end

  describe "#decorate_each_line" do
    it "decorates each text line with unstyled theme element" do
      expect(decorator.decorate_each_line(text, :em)).to eq(text)
    end

    it "decorates each text line with theme element styles" do
      expect(decorator.decorate_each_line(text, :strong)).to eq([
        "\e[34;1mTo produce a mighty book,\e[0m",
        "\e[34;1myou must choose a mighty theme.\e[0m"
      ].join("\n"))
    end
  end
end
