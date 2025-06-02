# frozen_string_literal: true

require "kramdown/parser/kramdown"

module TTY
  module Markdown
    class Parser < Kramdown::Parser::Kramdown
      FENCED_CODEBLOCK_MATCH = /
        ^[ ]{0,3}(([~`]){3,})\s*?((\S+?)(?:\?\S*)?)?\s*?\n
        (.*?)
        ^[ ]{0,3}\1\2*\s*?\n
      /mx.freeze

      FENCED_CODEBLOCK_START = /^[ ]{0,3}[~`]{3,}/.freeze
      private_constant :FENCED_CODEBLOCK_START

      define_parser(:codeblock_fenced_extension, FENCED_CODEBLOCK_START, nil,
                    :parse_codeblock_fenced)

      def initialize(source, options)
        super
        replace_fenced_codeblock_parser
      end

      private

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
