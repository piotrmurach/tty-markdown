# frozen_string_literal: true

require "rouge"

require_relative "decorator"
require_relative "formatter"
require_relative "theme"

module TTY
  class Markdown
    # Responsible for highlighting terminal code snippets
    #
    # @api private
    class Highlighter
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
        formatter.format(lexer.lex(code))
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

      # Select a formatter
      #
      # @return [Rouge::Formatter, TTY::Markdown::Formatter]
      #
      # @api private
      def formatter
        @formatter ||=
          if @mode < 256
            Formatter.new(Decorator.new(@pastel, Theme.from({code: @styles})))
          elsif @mode == 256
            Rouge::Formatters::Terminal256.new
          else
            Rouge::Formatters::TerminalTruecolor.new
          end
      end
    end # Highlighter
  end # Markdown
end # TTY
