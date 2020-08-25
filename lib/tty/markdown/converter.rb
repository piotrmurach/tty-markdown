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

      # Convert header element
      #
      # @param [Kramdown::Element] el
      #   the `kd:header` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
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
        result = opts[:result]
        content = []
        opts[:result] = content

        inner(el, opts)

        result << content.join.lines.map do |line|
          indent + @pastel.decorate(line.chomp, *styles) + NEWLINE
        end
      end

      # Convert paragraph element
      #
      # @param [Kramdown::Element] el
      #   the `kd:p` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_p(el, opts)
        indent = SPACE * @current_indent
        if ![:blockquote, :li].include?(opts[:parent].type)
          opts[:result] << indent
        end
        opts[:indent] = @current_indent
        if opts[:parent].type == :blockquote
          opts[:indent] = 0
        end

        inner(el, opts)

        unless opts[:result].last.to_s.end_with?(NEWLINE)
          opts[:result] << NEWLINE
        end
      end

      # Convert text element
      #
      # @param [Kramdown::Element] element
      #   the `kd:text` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_text(el, opts)
        text = Strings.wrap(el.value, @width - @current_indent)
        text = text.chomp if opts[:strip]
        indent = SPACE * opts[:indent]
        text = text.gsub(/\n/, "#{NEWLINE}#{indent}")
        opts[:result] << text
      end

      # Convert strong element
      #
      # @param [Kramdown::Element] element
      #   the `kd:strong` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_strong(el, opts)
        styles = Array(@theme[:strong])
        result = opts[:result]
        content = []
        opts[:result] = content

        inner(el, opts)

        result << content.join.lines.map do |line|
                    @pastel.decorate(line.chomp, *styles)
                  end.join(NEWLINE)
      end

      # Convert em element
      #
      # @param [Kramdown::Element] el
      #   the `kd:em` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_em(el, opts)
        styles = Array(@theme[:em])
        result = opts[:result]
        content = []
        opts[:result] = content

        inner(el, opts)

        result << content.join.lines.map do |line|
                    @pastel.decorate(line.chomp, *styles)
                  end.join(NEWLINE)
      end

      # Convert new line element
      #
      # @param [Kramdown::Element] el
      #   the `kd:blank` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_blank(el, opts)
        opts[:result] << NEWLINE
      end

      # Convert smart quote element
      #
      # @param [Kramdown::Element] el
      #   the `kd:smart_quote` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_smart_quote(el, opts)
        opts[:result] << @symbols[el.value]
      end

      # Convert codespan element
      #
      # @param [Kramdown::Element] el
      #   the `kd:codespan` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_codespan(el, opts)
        raw_code = Strings.wrap(el.value, @width - @current_indent)
        options = @color_opts.merge(el.options.merge(fenced: opts[:fenced]))
        highlighted = SyntaxHighliter.highlight(raw_code, **options)
        code = highlighted.split(NEWLINE).map.with_index do |line, i|
                 i.zero? ? line : line.insert(0, SPACE * @current_indent)
               end
        opts[:result] << code.join(NEWLINE)
      end

      # Convert codeblock element
      #
      # @param [Kramdown::Element] el
      #   the `kd:codeblock` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_codeblock(el, opts)
        opts[:result] << " " * @current_indent
        opts[:fenced] = false
        convert_codespan(el, opts)
      end

      # Convert blockquote element
      #
      # @param [Kramdown::Element] el
      #   the `kd:blockquote` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_blockquote(el, opts)
        indent = SPACE * @current_indent
        bar_symbol = @symbols[:bar]
        styles = Array(@theme[:quote])
        prefix = "#{indent}#{@pastel.decorate(bar_symbol, *styles)}  "

        result = opts[:result]
        content = []
        opts[:result] = content

        inner(el, opts)

        result << content.join.lines.map do |line|
                    prefix + line
                  end
      end

      # Convert ordered and unordered list element
      #
      # @param [Kramdown::Element] el
      #   the `kd:ul` or `kd:ol` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_ul(el, opts)
        @current_indent += @indent unless opts[:parent].type == :root
        inner(el, opts)
        @current_indent -= @indent unless opts[:parent].type == :root
      end
      alias convert_ol convert_ul
      alias convert_dl convert_ul

      # Convert list element
      #
      # @param [Kramdown::Element] el
      #   the `kd:li` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_li(el, opts)
        index = opts[:index] + 1
        styles = Array(@theme[:list])
        prefix_type = opts[:parent].type == :ol ? "#{index}." : @symbols[:bullet]
        prefix = @pastel.decorate(prefix_type, *styles) + SPACE
        opts[:strip] = true

        result = opts[:result]
        content = []
        opts[:result] = content

        inner(el, opts)

        result << SPACE * @current_indent
        result << prefix
        result << content.join
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

      # Convert table element
      #
      # @param [Kramdown::Element] el
      #   the `kd:table` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_table(el, opts)
        @row = 0
        @column = 0
        opts[:alignment] = el.options[:alignment]
        result = opts[:result]
        opts[:result] = []
        opts[:table_data] = extract_table_data(el, opts)
        opts[:result] = result
        opts[:column_widths] = distribute_widths(max_widths(opts[:table_data]))
        opts[:row_heights] = max_row_heights(opts[:table_data], opts[:column_widths])

        inner(el, opts)
      end

      # Extract table data
      #
      # @param [Kramdown::Element] el
      #   the `kd:table` element
      #
      # @api private
      def extract_table_data(el, opts)
        el.children.each_with_object([]) do |container, data|
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
      end

      # Distribute column widths inside total width
      #
      # @return [Array<Integer>]
      #
      # @api private
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

      # Calculate maximum widths for each column
      #
      # @return [Array<Integer>]
      #
      # @api private
      def max_widths(table_data)
        table_data.first.each_with_index.reduce([]) do |acc, (*, col)|
          acc << max_width(table_data, col)
          acc
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

      # Calculate maximum heights for each row
      #
      # @return [Array<Integer>]
      #
      # @api private
      def max_row_heights(table_data, column_widths)
        table_data.reduce([]) do |acc, row|
          acc << max_row_height(row, column_widths)
        end
      end

      # Calculate maximum cell height for a given row
      #
      # @return [Integer]
      #
      # @api private
      def max_row_height(row, column_widths)
        row.map.with_index do |column, col_index|
          Strings.wrap(column.join, column_widths[col_index]).lines.size
        end.max
      end

      # Convert thead element
      #
      # @param [Kramdown::Element] el
      #   the `kd:thead` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_thead(el, opts)
        indent = SPACE * @current_indent

        opts[:result] << indent
        opts[:result] << border(opts[:column_widths], :top)
        opts[:result] << "\n"
        inner(el, opts)
      end

      # Render horizontal border line
      #
      # @param [Array<Integer>] column_widths
      #   the table column widths
      # @param [Symbol] location
      #   location out of :top, :mid, :bottom
      #
      # @return [String]
      #
      # @api private
      def border(column_widths, location)
        symbols = @symbols
        result = []
        result << symbols[:"#{location}_left"]
        column_widths.each.with_index do |width, i|
          result << symbols[:"#{location}_center"] if i != 0
          result << (symbols[:line] * (width + 2))
        end
        result << symbols[:"#{location}_right"]
        styles = Array(@theme[:table])
        @pastel.decorate(result.join, *styles)
      end

      # Convert tbody element
      #
      # @param [Kramdown::Element] el
      #   the `kd:tbody` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_tbody(el, opts)
        indent = SPACE * @current_indent

        opts[:result] << indent
        if opts[:prev] && opts[:prev].type == :thead
          opts[:result] << border(opts[:column_widths], :mid)
        else
          opts[:result] << border(opts[:column_widths], :top)
        end
        opts[:result] << "\n"

        inner(el, opts)

        opts[:result] << indent
        if opts[:next] && opts[:next].type == :tfoot
          opts[:result] << border(opts[:column_widths], :mid)
        else
          opts[:result] << border(opts[:column_widths], :bottom)
        end
        opts[:result] << "\n"
      end

      # Convert tfoot element
      #
      # @param [Kramdown::Element] el
      #   the `kd:tfoot` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_tfoot(el, opts)
        indent = SPACE * @current_indent

        inner(el, opts)

        opts[:result] << indent
        opts[:result] << border(opts[:column_widths], :bottom)
        opts[:result] << "\n"
      end

      # Convert td element
      #
      # @param [Kramdown::Element] el
      #   the `kd:td` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_tr(el, opts)
        indent = SPACE * @current_indent

        if opts[:prev] && opts[:prev].type == :tr
          opts[:result] << indent
          opts[:result] << border(opts[:column_widths], :mid)
          opts[:result] << "\n"
        end

        opts[:row_cells] = []

        inner(el, opts)

        columns = opts[:row_cells].count

        row = opts[:row_cells].each_with_index.reduce([]) do |acc, (cell, i)|
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
        @row += 1
      end

      # Convert td element
      #
      # @param [Kramdown::Element] el
      #   the `kd:td` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_td(el, opts)
        indent = SPACE * @current_indent
        pipe_char = @symbols[:pipe]
        styles = Array(@theme[:table])
        row_cells = opts[:row_cells]
        pipe = @pastel.decorate(pipe_char, *styles)
        suffix = " #{pipe} "
        opts[:result] = []

        inner(el, opts)

        cell_content = opts[:result]
        cell_width = opts[:column_widths][@column]
        cell_height = opts[:row_heights][@row]
        alignment  = opts[:alignment][@column]
        align_opts = alignment == :default ? {} : { direction: alignment }

        wrapped = Strings.wrap(cell_content.join, cell_width)
        aligned = Strings.align(wrapped, cell_width, **align_opts)
        padded = if aligned.lines.size < cell_height
                   Strings.pad(aligned, [0, 0, cell_height - aligned.lines.size, 0])
                 else
                   aligned.dup
                 end

        row_cells << padded.lines.map do |line|
          # add pipe to first column
          (@column.zero? ? "#{indent}#{pipe} " : "") +
            (line.end_with?("\n") ? line.insert(-2, suffix) : line << suffix)
        end
        @column = (@column + 1) % opts[:column_widths].size
      end

      def convert_br(el, opts)
        opts[:result] << "\n"
      end

      # Convert hr element
      #
      # @param [Kramdown::Element] el
      #   the `kd:hr` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_hr(el, opts)
        symbols = @symbols
        width = @width - symbols[:diamond].length * 2
        styles = Array(@theme[:hr])
        line = symbols[:diamond] + symbols[:line] * width + symbols[:diamond]

        opts[:result] << @pastel.decorate(line, *styles)
        opts[:result] << "\n"
      end

      # Convert a element
      #
      # @param [Kramdown::Element] el
      #   the `kd:a` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
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

      # Convert image element
      #
      # @param [Kramdown::Element] element
      #   the `kd:img` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_img(el, opts)
        symbols = @symbols
        styles = Array(@theme[:image])
        src = el.attr["src"]
        alt = el.attr["alt"]
        link = [symbols[:paren_left]]
        unless alt.to_s.empty?
          link << "#{alt} #{symbols[:ndash]} "
        end
        link << "#{src}#{symbols[:paren_right]}"
        opts[:result] << @pastel.decorate(link.join, *styles)
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
