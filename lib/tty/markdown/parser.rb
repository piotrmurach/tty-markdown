# frozen_string_literal: true

require 'kramdown/converter'
require 'pastel'
require 'strings'
require 'tty-screen'

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
        @color_opts = {mode: options[:colors]}
        @width = options.fetch(:width) { TTY::Screen.width }
        @theme = options.fetch(:theme) { TTY::Markdown::THEME }
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
          options[:prev] = (i == 0 ? nil : el.children[i - 1])
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
        styles = Array(@theme[:header]).dup
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
          styles = Array(@theme[:list])
          opts[:result] << @pastel.decorate(symbol, *styles) + ' '
        end

        inner(el, opts)

        if opts[:parent].type == :blockquote
          format_blockquote(result_before, opts[:result])
        end

        unless opts[:result].last.end_with?("\n")
          opts[:result] << "\n"
        end
      end

      def format_blockquote(result_before, result)
        indent      = ' ' * @current_indent
        start_index = result_before.size
        max_index   = result.size - 1
        bar_symbol  = TTY::Markdown.symbols[:bar]
        styles = Array(@theme[:quote])
        prefix      = "#{indent}#{@pastel.decorate(bar_symbol, *styles)}  "

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
        styles = Array(@theme[:strong])
        opts[:result] <<  @pastel.lookup(*styles)
        inner(el, opts)
        opts[:result] << @pastel.lookup(:reset)
      end

      def convert_em(el, opts)
        styles = Array(@theme[:em])
        opts[:result] <<  @pastel.lookup(*styles)
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
        highlighted = SyntaxHighliter.highlight(raw_code, @color_opts.merge(opts))
        code = highlighted.split("\n").map.with_index do |line, i|
                if i == 0 # first line
                  line
                else
                  line.insert(0, ' ' * @current_indent)
                end
              end
        opts[:result] << code.join("\n")
      end

      def convert_codeblock(el, opts)
        opts[:fenced] = false
        convert_codespan(el, opts)
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

      def convert_table(el, opts)
        opts[:alignment] = el.options[:alignment]

        result = opts[:result]
        opts[:result] = []
        data = []

        el.children.each do |container|
          container.children.each do |row|
            data_row = []
            data << data_row
            row.children.each do |cell|
              opts[:result] = []
              cell_data = inner(cell, opts)
              data_row << cell_data[1][:result]
            end
          end
        end

        opts[:result] = result
        opts[:table_data] = data

        inner(el, opts)
      end

      def convert_thead(el, opts)
        indent = ' ' * @current_indent
        table_data = opts[:table_data]

        opts[:result] << indent
        opts[:result] << border(table_data, :top)
        opts[:result] << "\n"
        inner(el, opts)
      end

      # Render horizontal border line
      #
      # @param [Array[Array[String]]] table_data
      #   table rows and cells
      # @param [Symbol] location
      #   location out of :top, :mid, :bottom
      #
      # @return [String]
      #
      # @api private
      def border(table_data, location)
        symbols = TTY::Markdown.symbols
        result = []
        result << symbols[:"#{location}_left"]
        max_widths(table_data).each.with_index do |width, i|
          result << symbols[:"#{location}_center"] if i != 0
          result << (symbols[:line] * (width + 2))
        end
        result << symbols[:"#{location}_right"]
        styles = Array(@theme[:table])
        @pastel.decorate(result.join, *styles)
      end

      def convert_tbody(el, opts)
        indent = ' ' * @current_indent
        table_data = opts[:table_data]

        opts[:result] << indent
        if opts[:prev] && opts[:prev].type == :thead
          opts[:result] << border(table_data, :mid)
        else
          opts[:result] << border(table_data, :top)
        end
        opts[:result] << "\n"

        inner(el, opts)

        opts[:result] << indent
        opts[:result] << border(table_data, :bottom)
        opts[:result] << "\n"
      end

      def convert_tfoot(el, opts)
        innert(el, opts)
      end

      def convert_tr(el, opts)
        indent = ' ' * @current_indent
        pipe = TTY::Markdown.symbols[:pipe]
        styles = Array(@theme[:table])
        table_data = opts[:table_data]

        if opts[:prev] && opts[:prev].type == :tr
          opts[:result] << indent
          opts[:result] << border(table_data, :mid)
          opts[:result] << "\n"
        end

        opts[:result] << indent + @pastel.decorate("#{pipe} ", *styles)
        inner(el, opts)
        opts[:result] << "\n"
      end

      def convert_td(el, opts)
        pipe = TTY::Markdown.symbols[:pipe]
        styles = Array(@theme[:table])
        table_data = opts[:table_data]
        result = opts[:result]
        opts[:result] = []

        inner(el, opts)

        column = find_column(table_data, opts[:result])
        width = max_width(table_data, column)
        alignment = opts[:alignment][column]
        align_opts = alignment == :default ? {} : {direction: alignment}

        result << Strings.align(opts[:result].join, width, align_opts) <<
               " #{@pastel.decorate(pipe, *styles)} "
      end

      def find_column(table_data, cell)
        table_data.each do |row|
          row.size.times do |col|
            return col if row[col] == cell
          end
        end
      end

      def max_width(table_data, col)
        table_data.map { |row| Strings.sanitize(row[col].join).length }.max
      end

      def max_widths(table_data)
        table_data.first.each_with_index.reduce([]) do |acc, (*, col)|
          acc << max_width(table_data, col)
          acc
        end
      end

      def convert_hr(el, opts)
        indent = ' ' * @current_indent
        symbols = TTY::Markdown.symbols
        width = @width - (indent.length+1) * 2
        styles = Array(@theme[:hr])
        line = symbols[:diamond] + symbols[:line] * width + symbols[:diamond]

        opts[:result] << indent
        opts[:result] << @pastel.decorate(line, *styles)
        opts[:result] << "\n"
      end

      def convert_a(el, opts)
        symbols = TTY::Markdown.symbols
        styles = Array(@theme[:link])
        if el.children.size == 1 && el.children[0].type == :text
          opts[:result] << @pastel.decorate(el.attr['href'], *styles)
        else
          if el.attr['title']
           opts[:result] << el.attr['title']
          else
            inner(el, opts)
          end
          opts[:result] << " #{symbols[:arrow]} "
          opts[:result] << @pastel.decorate(el.attr['href'], *styles)
          opts[:result] << "\n"
        end
      end

      def convert_math(el, opts)
        if opts[:prev] && opts[:prev].type == :blank
          indent = ' ' * @current_indent
          opts[:result] << indent
        end
        convert_codespan(el, opts)
        opts[:result] << "\n"
      end

      def convert_abbreviation(el, opts)
        opts[:result] << el.value
      end

      def convert_footnote(*)
        warning("Footnotes are not supported")
      end

      def convert_raw(*)
        warning("Raw content is not supported")
      end

      def convert_img(*)
        warning("Images are not supported")
      end
    end # Parser
  end # Markdown
end # TTY
