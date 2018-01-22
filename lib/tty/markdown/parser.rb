# frozen_string_literal: true

require 'kramdown/converter'
require 'pastel'

require_relative 'syntax_highlighter'

module TTY
  module Markdown
    # Converts a Kramdown::Document tree to a terminal friendly output
    class Parser < Kramdown::Converter::Base

      def initialize(root, **options)
        super
        @stack = []
        @current_indent = 0
        @indent = options.fetch(:indent, 2)
        @pastel = Pastel.new
      end

      # Invoke an element conversion
      #
      # @api public
      def convert(el, opts = {indent: 0, result: []})
        send("convert_#{el.type}", el, opts)
      end

      private

      # Process children of this element
      def inner(el, opts)
        @stack << [el, opts]
        el.children.each_with_index do |inner_el, i|
          options = opts.dup
          options[:parent] = el
          options[:index] = i
          convert(inner_el, options)
        end
        @stack.pop
      end

      def convert_root(el, opts)
        inner(el, opts)
        opts[:result]
      end

      def convert_header(el, opts)
        level = el.options[:level]
        @current_indent = (level - 1) * @indent # Header determines indentation
        indent = ' ' * (level - 1) * @indent
        styles = [:cyan, :bold]
        styles << :underline if level == 1
        opts[:result] << indent + @pastel.lookup(*styles)
        inner(el, opts)
        opts[:result] << @pastel.lookup(:reset) + "\n"
      end

      def convert_p(el, opts)
        result_before = @stack.last[1][:result].dup
        indent = ' ' * @current_indent
        if opts[:parent].type != :blockquote
          opts[:result] << indent
        end

        case opts[:parent].type
        when :li
          bullet = TTY::Markdown.symbols[:bullet]
          index = @stack.last[1][:index] + 1
          symbol = opts[:ordered] ? "#{index}." : bullet
          opts[:result] << @pastel.yellow(symbol) + ' '
        end

        inner(el, opts)

        if opts[:parent].type == :blockquote
          format_blockquote(result_before, opts[:result])
        end

        opts[:result] << "\n"
      end

      def format_blockquote(result_before, result)
        indent      = ' ' * @current_indent
        start_index = result_before.size
        max_index   = result.size - 1
        bar_symbol  = TTY::Markdown.symbols[:bar]
        prefix      = "#{indent}#{@pastel.yellow(bar_symbol)} "

        result.map!.with_index do |str, i|
          if i == start_index
            str.insert(0, prefix)
          end

          if i >= start_index && str.include?("\n")
            str.lines.map! do |line|
              if line != str.lines.last || i < max_index
                line.insert(-1, prefix)
              else
                line
              end
            end
          else
            str
          end
        end
      end

      def convert_text(el, opts)
        text = el.value
        opts[:result] << text
      end

      def convert_strong(el, opts)
        opts[:result] <<  @pastel.lookup(:bold)
        inner(el, opts)
        opts[:result] << @pastel.lookup(:reset)
      end

      def convert_em(el, opts)
        opts[:result] << @pastel.lookup(:italic)
        inner(el, opts)
        opts[:result] << @pastel.lookup(:reset)
      end

      def convert_blank(el, opts)
        opts[:result] << "\n"
      end

      def convert_smart_quote(el, opts)
        inner(el, opts)
      end

      def convert_codespan(el, opts)
        raw_code = el.value
        highlighted = SyntaxHighliter.highlight(raw_code)
        code = highlighted.split("\n").map.with_index do |line, i|
                if i == 0 # first line
                  line
                else
                  line.insert(0, ' ' * @current_indent)
                end
              end
        opts[:result] << code.join("\n")
      end

      def convert_blockquote(el, opts)
        inner(el, opts)
      end

      def convert_ul(el, opts)
        @current_indent += @indent unless opts[:parent].type == :root
        inner(el, opts)
        @current_indent -= @indent unless opts[:parent].type == :root
      end
      alias convert_ol convert_ul

      def convert_li(el, opts)
        if opts[:parent].type == :ol
          opts[:ordered] = true
        end
        inner(el, opts)
      end
    end
  end # Markdown
end # TTY
