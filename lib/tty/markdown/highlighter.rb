# frozen_string_literal: true

require "rouge"

module TTY
  module Markdown
    # Responsible for highlighting terminal code snippets
    #
    # @api private
    module Highlighter
      # Highlight code snippet
      #
      # @param [String] code
      # @param [Integer] mode
      #   the color mode supported by the terminal
      # @param [String] lang
      #   the code snippet language
      # @param [Boolean] enabled
      #   whether or not coloring is enabled
      # @param [Proc] color
      #   the fallback coloring
      #
      # @api public
      def highlight(code, mode: 256, lang: nil, enabled: nil,
                    color: ->(line) { line })
        lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText

        if enabled == false
          code
        elsif 256 <= mode
          formatter = Rouge::Formatters::Terminal256.new
          formatter.format(lexer.lex(code))
        else
          code.lines.map { |line| color.(line.chomp) }.join("\n")
        end
      end
      module_function :highlight
    end # Highlighter
  end # Markdown
end # TTY
