# frozen_string_literal: true

require "kramdown/parser/kramdown"

module TTY
  module Markdown
    class Parser < Kramdown::Parser::Kramdown
      def initialize(source, options)
        super

        { codeblock_fenced: :codeblock_fenced_ext }.each do |current, replacement|
          @block_parsers[@block_parsers.index(current)] = replacement
        end
      end

      FENCED_CODEBLOCK_START = /^[ ]{0,3}[~`]{3,}/.freeze
      FENCED_CODEBLOCK_MATCH = /^[ ]{0,3}(([~`]){3,})\s*?((\S+?)(?:\?\S*)?)?\s*?\n(.*?)^[ ]{0,3}\1\2*\s*?\n/m.freeze

      define_parser(:codeblock_fenced_ext, FENCED_CODEBLOCK_START, nil,
                    "parse_codeblock_fenced")
    end # Parser
  end # Markdown
end # TTY

# Add the TTY::Markdown::Parser to the available Kramdown parsers
Kramdown::Parser.const_set(:TTYMarkdown, TTY::Markdown::Parser)
