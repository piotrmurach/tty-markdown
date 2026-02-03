# frozen_string_literal: true

require_relative "error"

module TTY
  class Markdown
    # Responsible for storing the theme configuration
    #
    # @api private
    class Theme
      # The element to style hash
      #
      # @return [Hash{Symbol => Array<Symbol>}]
      #
      # @api private
      ELEMENT_TO_STYLE = {
        code: %i[yellow],
        comment: %i[bright_black],
        delete: %i[red],
        em: %i[yellow],
        header: %i[cyan bold],
        heading1: %i[cyan bold underline],
        hr: %i[yellow],
        image: %i[bright_black],
        link: %i[yellow underline],
        list: %i[yellow],
        note: %i[yellow],
        quote: %i[yellow],
        strong: %i[yellow bold],
        table: %i[yellow]
      }.freeze
      private_constant :ELEMENT_TO_STYLE

      # Create a {TTY::Markdown::Theme} instance
      #
      # @example
      #   theme = TTY::Markdown::Theme.from({comment: :blue})
      #
      # @example
      #   theme = TTY::Markdown::Theme.from({comment: %i[blue underline]})
      #
      # @param [Hash{Symbol => Array<String, Symbol>, String, Symbol}] theme
      #   the theme configuration
      #
      # @return [TTY::Markdown::Theme]
      #
      # @raise [TTY::Markdown::Error]
      #   when the theme value is invalid
      #
      # @api public
      def self.from(theme)
        new(validate_names(build_theme(theme)))
      end

      # Build the theme hash
      #
      # @param [Hash{Symbol => Array<String, Symbol>, String, Symbol}] theme
      #   the theme configuration
      #
      # @return [Hash{Symbol => Array<Symbol>}]
      #
      # @raise [TTY::Markdown::Error]
      #   when the theme value is invalid
      #
      # @api private
      def self.build_theme(theme)
        raise_value_error(theme) unless theme.respond_to?(:to_h)

        ELEMENT_TO_STYLE.merge(theme.to_h) do |*, new_style|
          Array(new_style).map(&:to_sym)
        end
      end
      private_class_method :build_theme

      # Validate the elements names
      #
      # @param [Hash{Symbol => Array<Symbol>}] value
      #   the theme value
      #
      # @return [Hash{Symbol => Array<Symbol>}]
      #
      # @raise [TTY::Markdown::Error]
      #   when the element name is invalid
      #
      # @api private
      def self.validate_names(value)
        unknown_names = value.keys - ELEMENT_TO_STYLE.keys
        return value if unknown_names.empty?

        raise_name_error(*unknown_names)
      end
      private_class_method :validate_names

      # Raise the theme value error
      #
      # @param [Object] value
      #   the theme value
      #
      # @return [void]
      #
      # @raise [TTY::Markdown::Error]
      #   when the theme value is invalid
      #
      # @api private
      def self.raise_value_error(value)
        raise Error, "invalid theme: #{value.inspect}. " \
                     "Use the hash with the element name and style."
      end
      private_class_method :raise_value_error

      # Raise the element name error
      #
      # @param [Array<Symbol>] names
      #   the elements names
      #
      # @return [void]
      #
      # @raise [TTY::Markdown::Error]
      #   when the element name is invalid
      #
      # @api private
      def self.raise_name_error(*names)
        raise Error, "invalid theme element name#{"s" if names.size > 1}: " \
                     "#{names.map(&:inspect).join(", ")}."
      end
      private_class_method :raise_name_error

      # Create a {TTY::Markdown::Theme} instance
      #
      # @param [Hash{Symbol => Array<Symbol>}] theme
      #   the theme configuration
      #
      # @api private
      def initialize(theme)
        @theme = theme
      end
      private_class_method :new

      # Fetch styles by element name
      #
      # @example
      #   theme[:comment]
      #
      # @param [Symbol] name
      #   the element name
      #
      # @return [Array<Symbol>]
      #
      # @api public
      def [](name)
        @theme[name]
      end
    end # Theme
  end # Markdown
end # TTY
