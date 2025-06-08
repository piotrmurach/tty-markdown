# frozen_string_literal: true

require "rouge"

module TTY
  module Markdown
    # Responsible for highlighting terminal code snippets
    #
    # @api private
    class Highlighter
      # The newline character
      #
      # @return [String]
      #
      # @api private
      NEWLINE = "\n"
      private_constant :NEWLINE

      # Create a {TTY::Markdown::Highlighter} instance
      #
      # @example
      #   highlighter = TTY::Markdown::Highlighter.new(pastel)
      #
      # @param [Pastel] pastel
      #   the pastel
      # @param [Integer] mode
      #   the color mode
      # @param [Array<Symbol>, Symbol] styles
      #   the styles
      #
      # @api public
      def initialize(pastel, mode: 256, styles: [])
        @pastel = pastel
        @mode = mode
        @styles = styles
      end

      # Highlight the code snippet
      #
      # @example
      #   highlighter.highlight("puts 'TTY Toolkit'", "ruby")
      #
      # @param [String] code
      #   the code snippet
      # @param [String, nil] language
      #   the code language
      #
      # @return [String]
      #
      # @api public
      def highlight(code, language = nil)
        return code unless @pastel.enabled?

        lexer = select_lexer(code, language)

        if @mode < 256
          code.lines.map do |line|
            @pastel.decorate(line.chomp, *@styles)
          end.join(NEWLINE)
        else
          formatter = Rouge::Formatters::Terminal256.new
          formatter.format(lexer.lex(code))
        end
      end

      private

      # Select a lexer
      #
      # @param [String] code
      #   the code snippet
      # @param [String, nil] language
      #   the code language
      #
      # @return [Rouge::Lexer]
      #
      # @api private
      def select_lexer(code, language)
        Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText
      end
    end # Highlighter
  end # Markdown
end # TTY
