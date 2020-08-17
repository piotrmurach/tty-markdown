# frozen_string_literal: true

require "kramdown/parser/kramdown"

module Kramdown
  module Parser
    class KramdownExt < Kramdown::Parser::Kramdown
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
    end # KramdownExt
  end # Parser
end # TTY
