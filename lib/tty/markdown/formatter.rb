# frozen_string_literal: true

module TTY
  module Markdown
    # Responsible for formatting code snippets with standard terminal colors
    #
    # @api private
    class Formatter
      # The newline character
      #
      # @return [String]
      #
      # @api private
      NEWLINE = "\n"
      private_constant :NEWLINE

      # Create a {TTY::Markdown::Formatter} instance
      #
      # @example
      #   formatter = TTY::Markdown::Formatter.new(pastel, %i[yellow])
      #
      # @param [Pastel] pastel
      #   the pastel
      # @param [Array<Symbol>, Symbol] styles
      #   the styles
      #
      # @api public
      def initialize(pastel, styles)
        @pastel = pastel
        @styles = styles
      end

      # Format the Rouge lexer tokens
      #
      # @example
      #   formatter.format(tokens)
      #
      # @param [Enumerator] tokens
      #   the Rouge lexer tokens
      #
      # @return [String]
      #
      # @api public
      def format(tokens)
        code = tokens.map { |_token, value| value }.join
        code.lines.map do |line|
          @pastel.decorate(line.chomp, *@styles)
        end.join(NEWLINE)
      end
    end # Formatter
  end # Markdown
end # TTY
