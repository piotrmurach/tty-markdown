# frozen_string_literal: true

module TTY
  class Markdown
    # Responsible for decorating text with theme element styles
    #
    # @api private
    class Decorator
      # The newline character
      #
      # @return [String]
      #
      # @api private
      NEWLINE = "\n"
      private_constant :NEWLINE

      # Create a {TTY::Markdown::Decorator} instance
      #
      # @example
      #   decorator = TTY::Markdown::Decorator.new(pastel, theme)
      #
      # @param [Pastel] pastel
      #   the pastel
      # @param [TTY::Markdown::Theme] theme
      #   the theme
      #
      # @api public
      def initialize(pastel, theme)
        @pastel = pastel
        @theme = theme
      end

      # Detect whether text decoration is enabled
      #
      # @example
      #   decorator.enabled?
      #
      # @return [Boolean]
      #
      # @api public
      def enabled?
        @pastel.enabled?
      end

      # Decorate text with theme element styles
      #
      # @example
      #   decorator.decorate("TTY Toolkit", :strong)
      #
      # @param [String] text
      #   the text
      # @param [Symbol] name
      #   the theme element name
      #
      # @return [String]
      #
      # @api public
      def decorate(text, name)
        @pastel.decorate(text, *@theme[name])
      end

      # Decorate each text line with theme element styles
      #
      # @example
      #   decorator.decorate_each_line("TTY\nToolkit", :strong)
      #
      # @param [String] text
      #   the text
      # @param [Symbol] name
      #   the theme element name
      #
      # @return [String]
      #
      # @api public
      def decorate_each_line(text, name)
        text.lines.map do |line|
          decorate(line.chomp, name)
        end.join(NEWLINE)
      end
    end # Decorator
  end # Markdown
end # TTY
