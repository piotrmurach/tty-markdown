# frozen_string_literal: true

require 'pastel'
require 'rouge'
require 'tty-color'

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
        lang = nil
        start_line = code.lines[0]
        if available_lexers.include?(start_line.strip.downcase)
          lang = start_line.strip.downcase
        end
      end
      module_function :guess_lang

      # Highlight code snippet
      #
      # @api public
      def highlight(code, **options)
        lang = guess_lang(code)
        mode = options[:mode] || TTY::Color.mode
        lines = code.dup.lines
        if options[:fenced].nil?
          code = lines[1...-1].join + lines[-1].strip
        end

        lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText

        if mode >= 256
          formatter = Rouge::Formatters::Terminal256.new
          formatter.format(lexer.lex(code))
        else
          pastel = Pastel.new
          code.split("\n").map { |line| pastel.yellow(line) }.join("\n")
        end
      end
      module_function :highlight
    end # SyntaxHighlighter
  end # Markdown
end # TTY
