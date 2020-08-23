# frozen_string_literal: true

require "kramdown/converter"
require "pastel"
require "strings"

require_relative "syntax_highlighter"

module TTY
  module Markdown
    # Converts a Kramdown::Document tree to a terminal friendly output
    class Converter < ::Kramdown::Converter::Base
      NEWLINE = "\n"
      SPACE = " "

      def initialize(root, options = {})
        super
        @stack = []
        @current_indent = 0
        @indent = options[:indent]
        @pastel = Pastel.new
        @color_opts = { mode: options[:colors] }
        @width = options[:width]
        @theme = options[:theme]
        @symbols = options[:symbols]
      end

      # Invoke an element conversion
      #
      # @api public
      def convert(el, opts = { indent: 0, result: [] })
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
          options[:next] = (i == el.children.length - 1 ? nil : el.children[i + 1])
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
        if opts[:parent] && opts[:parent].type == :root
          # Header determines indentation only at top level
          @current_indent = (level - 1) * @indent
          indent = SPACE * (level - 1) * @indent
        else
          indent = SPACE * @current_indent
        end
        styles = Array(@theme[:header]).dup
        styles << :underline if level == 1
        opts[:result] << indent + @pastel.lookup(*styles)
        inner(el, opts)
        opts[:result] << @pastel.lookup(:reset) + NEWLINE
      end

      def convert_p(el, opts)
        result_before = @stack.last[1][:result].dup
        indent = SPACE * @current_indent

        if opts[:parent].type != :blockquote
          opts[:result] << indent
        end

        opts[:indent] = @current_indent
        opts[:strip] = false

        case opts[:parent].type
        when :li
          bullet = @symbols[:bullet]
          index = @stack.last[1][:index] + 1
          symbol = opts[:ordered] ? "#{index}." : bullet
          styles = Array(@theme[:list])
          opts[:result] << @pastel.decorate(symbol, *styles) + SPACE
          opts[:indent] += @indent
          opts[:strip] = true
        when :blockquote
          opts[:indent] = 0
        end

        inner(el, opts)

        if opts[:parent].type == :blockquote
          format_blockquote(result_before, opts[:result])
        end

        unless opts[:result].last.to_s.end_with?(NEWLINE)
          opts[:result] << NEWLINE
        end
      end

      # Format current element by inserting prefix for each
      # quoted line within the allowed screen size.
      #
      # @param [Array[String]] result_before
      # @param [Array[String]] result
      #
      # @return [nil]
      #
      # @api private
      def format_blockquote(result_before, result)
        indent      = SPACE * @current_indent
        start_index = result_before.size
        max_index   = result.size - 1
        bar_symbol  = @symbols[:bar]
        styles      = Array(@theme[:quote])
        prefix      = "#{indent}#{@pastel.decorate(bar_symbol, *styles)}  "

        result.map!.with_index do |str, i|
          if i == start_index
            str.insert(0, prefix)
          end

          # only modify blockquote element
          if i >= start_index && str.to_s.include?(NEWLINE) # multiline string found
            str.lines.map! do |line|
              if (line != str.lines.last || i < max_index)
                line.insert(-1, line.end_with?(NEWLINE) ? prefix : NEWLINE + prefix)
              else
                line
              end
            end.join
          else
            str
          end
        end
      end

      def convert_text(el, opts)
        text = Strings.wrap(el.value, @width - @current_indent)
        text = text.chomp if opts[:strip]
        indent = SPACE * opts[:indent]
        text = text.gsub(/\n/, "#{NEWLINE}#{indent}")
        opts[:result] << text
      end

      def convert_strong(el, opts)
        styles = Array(@theme[:strong])
        opts[:result] << @pastel.lookup(*styles)
        inner(el, opts)
        opts[:result] << @pastel.lookup(:reset)
      end

      def convert_em(el, opts)
        styles = Array(@theme[:em])
        opts[:result] << @pastel.lookup(*styles)
        inner(el, opts)
        opts[:result] << @pastel.lookup(:reset)
      end

      def convert_blank(el, opts)
        opts[:result] << NEWLINE
      end

      def convert_smart_quote(el, opts)
        opts[:result] << @symbols[el.value]
      end

      def convert_codespan(el, opts)
        raw_code = Strings.wrap(el.value, @width - @current_indent)
        options = @color_opts.merge(el.options.merge(fenced: opts[:fenced]))
        highlighted = SyntaxHighliter.highlight(raw_code, **options)
        code = highlighted.split(NEWLINE).map.with_index do |line, i|
                 i.zero? ? line : line.insert(0, SPACE * @current_indent)
               end
        opts[:result] << code.join(NEWLINE)
      end

      def convert_codeblock(el, opts)
        opts[:result] << " " * @current_indent
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
      alias convert_dl convert_ul

      def convert_li(el, opts)
        if opts[:parent].type == :ol
          opts[:ordered] = true
        end
        inner(el, opts)
      end

      # Convert dt element
      #
      # @param [Kramdown::Element] el
      #   the `kd:dt` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_dt(el, opts)
        opts[:result] << " " * @current_indent
        inner(el, opts)
        opts[:result] << "\n"
      end

      # Convert dd element
      #
      # @param [Kramdown::Element] el
      #   the `kd:dd` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_dd(el, opts)
        @current_indent += @indent unless opts[:parent].type == :root
        inner(el, opts)
        @current_indent -= @indent unless opts[:parent].type == :root
        opts[:result] << "\n" if opts[:next] && opts[:next].type == :dt
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
        indent = SPACE * @current_indent
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
        symbols = @symbols
        result = []
        result << symbols[:"#{location}_left"]
        distribute_widths(max_widths(table_data)).each.with_index do |width, i|
          result << symbols[:"#{location}_center"] if i != 0
          result << (symbols[:line] * (width + 2))
        end
        result << symbols[:"#{location}_right"]
        styles = Array(@theme[:table])
        @pastel.decorate(result.join, *styles)
      end

      def convert_tbody(el, opts)
        indent = SPACE * @current_indent
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
        inner(el, opts)
      end

      def convert_tr(el, opts)
        indent = SPACE * @current_indent
        table_data = opts[:table_data]

        if opts[:prev] && opts[:prev].type == :tr
          opts[:result] << indent
          opts[:result] << border(table_data, :mid)
          opts[:result] << "\n"
        end

        opts[:cells] = []

        inner(el, opts)

        columns = table_data.first.count

        row = opts[:cells].each_with_index.reduce([]) do |acc, (cell, i)|
          if cell.size > 1 # multiline
            cell.each_with_index do |c, j| # zip columns
              acc[j] = [] if acc[j].nil?
              acc[j] << c.chomp
              acc[j] << "\n" if i == (columns - 1)
            end
          else
            acc << cell
            acc << "\n" if i == (columns - 1)
          end
          acc
        end.join

        opts[:result] << row
      end

      def convert_td(el, opts)
        indent = SPACE * @current_indent
        pipe       = @symbols[:pipe]
        styles     = Array(@theme[:table])
        table_data = opts[:table_data]
        result     = opts[:cells]
        suffix     = " #{@pastel.decorate(pipe, *styles)} "
        opts[:result] = []

        inner(el, opts)

        row, column = *find_row_column(table_data, opts[:result])
        cell_widths = distribute_widths(max_widths(table_data))
        cell_width = cell_widths[column]
        cell_height = max_height(table_data, row, cell_widths)
        alignment  = opts[:alignment][column]
        align_opts = alignment == :default ? {} : { direction: alignment }

        wrapped = Strings.wrap(opts[:result].join, cell_width)
        aligned = Strings.align(wrapped, cell_width, **align_opts)
        padded = if aligned.lines.size < cell_height
                   Strings.pad(aligned, [0, 0, cell_height - aligned.lines.size, 0])
                 else
                   aligned.dup
                 end

        result << padded.lines.map do |line|
          # add pipe to first column
          (column.zero? ? "#{indent}#{@pastel.decorate(pipe, *styles)} " : "") +
            (line.end_with?("\n") ? line.insert(-2, suffix) : line << suffix)
        end
      end

      # Find row and column indexes
      #
      # @return [Array[Integer, Integer]]
      #
      # @api private
      def find_row_column(table_data, cell)
        table_data.each_with_index do |row, row_no|
          row.size.times do |col|
            return [row_no, col] if row[col] == cell
          end
        end
      end

      # Calculate maximum cell width for a given column
      #
      # @return [Integer]
      #
      # @api private
      def max_width(table_data, col)
        table_data.map do |row|
          Strings.sanitize(row[col].join).lines.map(&:length).max || 0
        end.max
      end

      # Calculate maximum cell height for a given row
      #
      # @return [Integer]
      #
      # @api private
      def max_height(table_data, row, cell_widths)
        table_data[row].map.with_index do |col, i|
          Strings.wrap(col.join, cell_widths[i]).lines.size
        end.max
      end

      def max_widths(table_data)
        table_data.first.each_with_index.reduce([]) do |acc, (*, col)|
          acc << max_width(table_data, col)
          acc
        end
      end

      def distribute_widths(widths)
        indent = SPACE * @current_indent
        total_width = widths.reduce(&:+)
        screen_width = @width - (indent.length + 1) * 2 - (widths.size + 1)
        return widths if total_width <= screen_width

        extra_width = total_width - screen_width

        widths.map do |w|
          ratio = w / total_width.to_f
          w - (extra_width * ratio).floor
        end
      end

      def convert_br(el, opts)
        opts[:result] << "\n"
      end

      def convert_hr(el, opts)
        symbols = @symbols
        width = @width - symbols[:diamond].length * 2
        styles = Array(@theme[:hr])
        line = symbols[:diamond] + symbols[:line] * width + symbols[:diamond]

        opts[:result] << @pastel.decorate(line, *styles)
        opts[:result] << "\n"
      end

      def convert_a(el, opts)
        symbols = @symbols
        styles = Array(@theme[:link])

        if URI.parse(el.attr["href"]).class == URI::MailTo
          el.attr["href"] = URI.parse(el.attr["href"]).to
        end

        if el.children.size == 1 && el.children[0].type == :text &&
           el.children[0].value == el.attr["href"]

          if !el.attr["title"].nil? && !el.attr["title"].strip.empty?
            opts[:result] << "(#{el.attr["title"]}) "
          end
          opts[:result] << @pastel.decorate(el.attr["href"], *styles)

        elsif el.children.size > 0  &&
             (el.children[0].type != :text || !el.children[0].value.strip.empty?)

          inner(el, opts)
          opts[:result] << " #{symbols[:arrow]} "
          if el.attr["title"]
            opts[:result] << "(#{el.attr["title"]}) "
          end
          opts[:result] << @pastel.decorate(el.attr["href"], *styles)
        end
      end

      # Convert math element
      #
      # @param [Kramdown::Element] el
      #   the `kd:math` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_math(el, opts)
        if el.options[:category] == :block
          convert_codeblock(el, opts)
          opts[:result] << NEWLINE
        else
          convert_codespan(el, opts)
        end
      end

      # Convert abbreviation element
      #
      # @param [Kramdown::Element] el
      #   the `kd:abbreviation` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_abbreviation(el, opts)
        title = @root.options[:abbrev_defs][el.value]
        opts[:result] << el.value
        unless title.to_s.empty?
          opts[:result] << "(#{title})"
        end
      end

      def convert_typographic_sym(el, opts)
        opts[:result] << @symbols[el.value]
      end

      def convert_entity(el, opts)
        opts[:result] << unicode_char(el.value.code_point)
      end

      # Convert codepoint to UTF-8 representation
      def unicode_char(codepoint)
        [codepoint].pack("U*")
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

      def convert_html_element(el, opts)
        if el.value == "del"
          styles = Array(@theme[:strong])
          opts[:result] << @pastel.lookup(*styles)
          inner(el, opts)
          opts[:result] << @pastel.lookup(:reset)
        elsif el.children.size > 0
          inner(el, opts)
        elsif el.value == "br"
          opts[:result] << "\n"
        else
          warning("HTML element '#{el.value.inspect}' not supported")
        end
      end

      def convert_xml_comment(el, opts)
        opts[:result] << el.value
      end
      alias convert_comment convert_xml_comment
    end # Parser
  end # Markdown
end # TTY
