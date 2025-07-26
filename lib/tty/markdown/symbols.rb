# frozen_string_literal: true

require_relative "error"

module TTY
  class Markdown
    # Responsible for storing the symbols configuration
    #
    # @api private
    class Symbols
      # The ASCII name
      #
      # @return [String]
      #
      # @api private
      ASCII = "ascii"
      private_constant :ASCII

      # The name to the ASCII symbol hash
      #
      # @return [Hash{Symbol => String}]
      #
      # @api private
      NAME_TO_ASCII = {
        arrow: "->",
        bar: "|",
        bottom_center: "+",
        bottom_right: "+",
        bottom_left: "+",
        bracket_left: "[",
        bracket_right: "]",
        bullet: "*",
        diamond: "*",
        hash: "#",
        hellip: "...",
        laquo: "<<",
        laquo_space: "<< ",
        ldquo: "\"",
        line: "-",
        lsquo: "\"",
        mdash: "--",
        mid_center: "+",
        mid_left: "+",
        mid_right: "+",
        ndash: "-",
        paren_left: "(",
        paren_right: ")",
        pipe: "|",
        raquo: ">>",
        raquo_space: " >>",
        rdquo: "\"",
        rsquo: "\"",
        top_center: "+",
        top_left: "+",
        top_right: "+"
      }.freeze
      private_constant :NAME_TO_ASCII

      # The name to the Unicode symbol hash
      #
      # @return [Hash{Symbol => String}]
      #
      # @api private
      NAME_TO_UNICODE = {
        arrow: "»",
        bar: "┃",
        bottom_center: "┴",
        bottom_right: "┘",
        bottom_left: "└",
        bracket_left: "[",
        bracket_right: "]",
        bullet: "●",
        diamond: "◈",
        hash: "#",
        hellip: "…",
        laquo: "«",
        laquo_space: "« ",
        ldquo: "“",
        line: "─",
        lsquo: "‘",
        mdash: "\u2014",
        mid_center: "┼",
        mid_left: "├",
        mid_right: "┤",
        ndash: "-",
        paren_left: "(",
        paren_right: ")",
        pipe: "│",
        raquo: "»",
        raquo_space: " »",
        rdquo: "”",
        rsquo: "’",
        top_center: "┬",
        top_left: "┌",
        top_right: "┐"
      }.freeze
      private_constant :NAME_TO_UNICODE

      # The Unicode name
      #
      # @return [String]
      #
      # @api private
      UNICODE = "unicode"
      private_constant :UNICODE

      # Create a {TTY::Markdown::Symbols} instance
      #
      # @example
      #   symbols = TTY::Markdown::Symbols.from(:ascii)
      #
      # @example
      #   symbols = TTY::Markdown::Symbols.from({
      #     base: :ascii,
      #     override: {
      #       arrow: "=>"
      #     }
      #   })
      #
      # @param [Hash, String, Symbol] symbols
      #   the symbols configuration
      #
      # @return [TTY::Markdown::Symbols]
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbols value is invalid
      #
      # @api public
      def self.from(symbols)
        new(build_symbols(symbols))
      end

      # Build the symbols hash
      #
      # @param [Hash, String, Symbol] symbols
      #   the symbols configuration
      #
      # @return [Hash{Symbol => String}]
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbols value is invalid
      #
      # @api private
      def self.build_symbols(symbols)
        case symbols
        when String, Symbol
          select_symbols(symbols)
        when Hash
          base_symbols = select_symbols(symbols.fetch(:base, UNICODE))
          base_symbols.merge(symbols[:override].to_h)
        else
          raise_value_error(symbols)
        end
      end
      private_class_method :build_symbols

      # Select either ASCII or Unicode symbols
      #
      # @param [String, Symbol] name
      #   the symbols name
      #
      # @return [Hash{Symbol => String}]
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbols name is invalid
      #
      # @api private
      def self.select_symbols(name)
        case name.to_s
        when ASCII   then NAME_TO_ASCII
        when UNICODE then NAME_TO_UNICODE
        else raise_symbols_name_error(name)
        end
      end
      private_class_method :select_symbols

      # Raise the symbols value error
      #
      # @param [Object] value
      #   the symbols value
      #
      # @return [void]
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbols value is invalid
      #
      # @api private
      def self.raise_value_error(value)
        raise Error, "invalid symbols: #{value.inspect}. " \
                     "Use a hash with base and override keys or a symbol."
      end
      private_class_method :raise_value_error

      # Raise the symbols name error
      #
      # @param [String, Symbol] name
      #   the symbols name
      #
      # @return [void]
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbols name is invalid
      #
      # @api private
      def self.raise_symbols_name_error(name)
        raise Error, "invalid symbols name: #{name.inspect}. " \
                     "Use the :#{ASCII} or :#{UNICODE} name."
      end
      private_class_method :raise_symbols_name_error

      # Create a {TTY::Markdown::Symbols} instance
      #
      # @param [Hash{Symbol => String}] symbols
      #   the symbols configuration
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbol name is invalid
      #
      # @api private
      def initialize(symbols)
        @symbols = validate(symbols)
      end
      private_class_method :new

      # Fetch a symbol by name
      #
      # @example
      #   symbols[:arrow]
      #
      # @param [Symbol] name
      #   the symbol name
      #
      # @return [String]
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbol name is invalid
      #
      # @api public
      def [](name)
        @symbols.fetch(name) do
          raise_name_error(name)
        end
      end

      # Wrap the content in brackets
      #
      # @example
      #   symbols.wrap_in_brackets("TTY Toolkit")
      #
      # @param [String] content
      #   the content
      #
      # @return [String]
      #
      # @api public
      def wrap_in_brackets(content)
        "#{self[:bracket_left]}#{content}#{self[:bracket_right]}"
      end

      # Wrap the content in parentheses
      #
      # @example
      #   symbols.wrap_in_parentheses("TTY Toolkit")
      #
      # @param [String] content
      #   the content
      #
      # @return [String]
      #
      # @api public
      def wrap_in_parentheses(content)
        "#{self[:paren_left]}#{content}#{self[:paren_right]}"
      end

      private

      # Validate the symbols names
      #
      # @param [Hash{Symbol => String}] value
      #   the symbols value
      #
      # @return [Hash{Symbol => String}]
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbol name is invalid
      #
      # @api private
      def validate(value)
        unknown_names = value.keys - NAME_TO_ASCII.keys
        return value if unknown_names.empty?

        raise_name_error(*unknown_names)
      end

      # Raise the symbol name error
      #
      # @param [Array<Symbol>] names
      #   the symbols names
      #
      # @return [void]
      #
      # @raise [TTY::Markdown::Error]
      #   when the symbol name is invalid
      #
      # @api private
      def raise_name_error(*names)
        raise Error, "invalid symbol name#{"s" if names.size > 1}: " \
                     "#{names.map(&:inspect).join(", ")}."
      end
    end # Symbols
  end # Markdown
end # TTY
