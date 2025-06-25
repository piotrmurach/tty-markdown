# frozen_string_literal: true

require_relative "error"

module TTY
  class Markdown
    # Responsible for storing the color configuration
    #
    # @api private
    class Color
      # The always name
      #
      # @return [String]
      #
      # @api private
      ALWAYS = "always"
      private_constant :ALWAYS

      # The auto name
      #
      # @return [String]
      #
      # @api private
      AUTO = "auto"
      private_constant :AUTO

      # The never name
      #
      # @return [String]
      #
      # @api private
      NEVER = "never"
      private_constant :NEVER

      # The allowed modes
      #
      # @return [Array<String>]
      #
      # @api private
      MODES = [ALWAYS, AUTO, NEVER].freeze
      private_constant :MODES

      # Create a {TTY::Markdown::Color} instance
      #
      # @example
      #   color = TTY::Markdown::Color.new(:always)
      #
      # @param [String, Symbol] color
      #   the color configuration
      #
      # @raise [TTY::Markdown::Error]
      #   when the color is invalid
      #
      # @api public
      def initialize(color)
        @color = validate(color)
      end

      # Convert to the Pastel enabled option
      #
      # @example
      #   color.to_enabled
      #
      # @return [Boolean, nil]
      #
      # @api public
      def to_enabled
        case @color.to_s
        when ALWAYS then true
        when NEVER  then false
        end
      end

      private

      # Validate the color value
      #
      # @param [String, Symbol] value
      #   the color value
      #
      # @return [String, Symbol]
      #
      # @raise [TTY::Markdown::Error]
      #   when the color value is invalid
      #
      # @api private
      def validate(value)
        return value if MODES.include?(value.to_s)

        raise_value_error(value)
      end

      # Raise the color value error
      #
      # @param [Object] value
      #   the color value
      #
      # @return [void]
      #
      # @raise [TTY::Markdown::Error]
      #   when the color value is invalid
      #
      # @api private
      def raise_value_error(value)
        raise Error, "invalid color: #{value.inspect}. Use the " \
                     ":#{ALWAYS}, :#{AUTO} or :#{NEVER} value."
      end
    end # Color
  end # Markdown
end # TTY
