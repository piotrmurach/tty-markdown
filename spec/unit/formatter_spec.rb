# frozen_string_literal: true

RSpec.describe TTY::Markdown::Formatter do
  subject(:formatter) { described_class.new(decorator) }

  let(:code) { "class Greeter\n  def say\n    \"hello\"\n  end\nend" }
  let(:decorator) { TTY::Markdown::Decorator.new(pastel, theme) }
  let(:pastel) { Pastel.new(enabled: true) }
  let(:theme) { TTY::Markdown::Theme.from({code: %i[blue bold]}) }

  describe "#format" do
    context "with the plain text lexer" do
      let(:lexer) { Rouge::Lexers::PlainText.new }

      it "formats tokens with standard color and style" do
        tokens = lexer.lex(code)

        expect(formatter.format(tokens)).to eq([
          "\e[34;1mclass Greeter\e[0m",
          "\e[34;1m  def say\e[0m",
          "\e[34;1m    \"hello\"\e[0m",
          "\e[34;1m  end\e[0m",
          "\e[34;1mend\e[0m"
        ].join("\n"))
      end
    end

    context "with the Ruby lexer" do
      let(:lexer) { Rouge::Lexers::Ruby.new }

      it "formats tokens with standard color and style" do
        tokens = lexer.lex(code)

        expect(formatter.format(tokens)).to eq([
          "\e[34;1mclass Greeter\e[0m",
          "\e[34;1m  def say\e[0m",
          "\e[34;1m    \"hello\"\e[0m",
          "\e[34;1m  end\e[0m",
          "\e[34;1mend\e[0m"
        ].join("\n"))
      end
    end
  end
end
