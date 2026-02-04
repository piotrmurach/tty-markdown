# frozen_string_literal: true

require "rouge"

require_relative "formatter"

module TTY
  class Markdown
    # Responsible for highlighting terminal code snippets
    #
    # @api private
    class Highlighter
      # Create a {TTY::Markdown::Highlighter} instance
      #
      # @example
      #   highlighter = TTY::Markdown::Highlighter.new(decorator)
      #
      # @param [TTY::Markdown::Decorator] decorator
      #   the decorator
      # @param [Integer] mode
      #   the color mode
      #
      # @api public
      def initialize(decorator, mode: 256)
        @decorator = decorator
        @mode = mode
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
        return code unless @decorator.enabled?

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
            Formatter.new(@decorator)
          elsif @mode == 256
            Rouge::Formatters::Terminal256.new
          else
            Rouge::Formatters::TerminalTruecolor.new
          end
      end
    end # Highlighter
  end # Markdown
end # TTY
