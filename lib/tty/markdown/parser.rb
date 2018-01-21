# frozen_string_literal: true

require 'kramdown/converter'
require 'pastel'

module TTY
  module Markdown
    # Converts a Kramdown::Document tree to a terminal friendly output
    class Parser < Kramdown::Converter::Base

      def initialize(root, **options)
        super
        @pastel = Pastel.new
        @stack = []
        @current_indent = 0
        @indent = options.fetch(:indent, 2)
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
        opts[:result] << indent + @pastel.lookup(:cyan, :bold)
        inner(el, opts)
        opts[:result] << @pastel.lookup(:reset) + "\n"
      end

      def convert_p(el, opts)
        opts[:result] << ' ' * @current_indent
        case opts[:parent].type
        when :li
          bullet = TTY::Markdown.symbols[:bullet]
          index = @stack.last[1][:index] + 1
          symbol = opts[:ordered] ? "#{index}." : bullet
          opts[:result] << symbol + ' '
        end

        inner(el, opts)

        if opts[:parent].type == :blockquote
          last_lines = opts[:result][-1].split("\n")
          lines_quoted = last_lines.map { |line| line.insert(0, "| ") }
          opts[:result][-1] = lines_quoted.join("\n")
        end
        opts[:result] << "\n"
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
        opts[:result] << @pastel.lookup(:yellow)
        opts[:result] << el.value
        opts[:result] << @pastel.lookup(:reset)
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
