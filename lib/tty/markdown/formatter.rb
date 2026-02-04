# frozen_string_literal: true

module TTY
  class Markdown
    # Responsible for formatting code snippets with standard terminal colors
    #
    # @api private
    class Formatter
      # Create a {TTY::Markdown::Formatter} instance
      #
      # @example
      #   formatter = TTY::Markdown::Formatter.new(decorator)
      #
      # @param [TTY::Markdown::Decorator] decorator
      #   the decorator
      #
      # @api public
      def initialize(decorator)
        @decorator = decorator
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
        @decorator.decorate_each_line(code, :code)
      end
    end # Formatter
  end # Markdown
end # TTY
