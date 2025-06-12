# frozen_string_literal: true

require "kramdown/parser/kramdown"

module TTY
  class Markdown
    # Responsible for parsing standard and extended Markdown syntax
    #
    # @api private
    class Parser < Kramdown::Parser::Kramdown
      # The fenced code block pattern
      #
      # @return [Regexp]
      #
      # @api private
      FENCED_CODEBLOCK_MATCH = /
        ^[ ]{0,3}(([~`]){3,})\s*?((\S+?)(?:\?\S*)?)?\s*?\n
        (.*?)
        ^[ ]{0,3}\1\2*\s*?\n
      /mx.freeze

      # The fenced code block start pattern
      #
      # @return [Regexp]
      #
      # @api private
      FENCED_CODEBLOCK_START = /^[ ]{0,3}[~`]{3,}/.freeze
      private_constant :FENCED_CODEBLOCK_START

      define_parser(:codeblock_fenced_extension, FENCED_CODEBLOCK_START, nil,
                    :parse_codeblock_fenced)

      # Create a {TTY::Markdown::Parser} instance
      #
      # @example
      #   parser = TTY::Markdown::Parser.new("# TTY Toolkit", {})
      #
      # @param [String] source
      #   the Markdown source
      # @param [Hash] options
      #   the parsing options
      #
      # @api private
      def initialize(source, options)
        super
        replace_fenced_codeblock_parser
      end

      private

      # Replace the fenced code block parser
      #
      # @return [void]
      #
      # @api private
      def replace_fenced_codeblock_parser
        @block_parsers[
          @block_parsers.index(:codeblock_fenced)
        ] = :codeblock_fenced_extension
      end
    end # Parser
  end # Markdown
end # TTY

# Add the TTY::Markdown::Parser to the available Kramdown parsers
Kramdown::Parser.const_set(:TTYMarkdown, TTY::Markdown::Parser)
