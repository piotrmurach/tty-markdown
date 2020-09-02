# frozen_string_literal: true

require "pastel"
require "rouge"

module TTY
  module Markdown
    # Syntax highlighting for terminal code snippets
    #
    # @api private
    module SyntaxHighliter
      # Return all available language lexers
      #
      # @return [Array[String]]
      #
      # @api private
      def available_lexers
        Rouge::Lexer.all.sort_by(&:tag).inject([]) do |names, lexer|
          names << lexer.tag
          if lexer.aliases.any?
            lexer.aliases.each { |a| names << a }
          end
          names
        end
      end
      module_function :available_lexers

      # Guess langauge from code snippet
      #
      # @return [String, nil]
      #
      # @api private
      def guess_lang(code)
        start_line = code.lines[0]
        if available_lexers.include?(start_line.strip.downcase)
          start_line.strip.downcase
        end
      end
      module_function :guess_lang

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
        lang = guess_lang(code) if lang.nil?
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
    end # SyntaxHighlighter
  end # Markdown
end # TTY
