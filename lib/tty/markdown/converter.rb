# frozen_string_literal: true

require "kramdown/converter"
require "kramdown/element"
require "pastel"
require "strings"
require "uri"

require_relative "syntax_highlighter"

module TTY
  module Markdown
    # Converts a Kramdown::Document tree to a terminal friendly output
    class Converter < ::Kramdown::Converter::Base
      # The empty string
      #
      # @return [String]
      #
      # @api private
      EMPTY = ""
      private_constant :EMPTY

      # The indented HTML elements
      #
      # @return [Array<Symbol>]
      #
      # @api private
      INDENTED_HTML_ELEMENTS = %i[blockquote li].freeze
      private_constant :INDENTED_HTML_ELEMENTS

      # The newline character
      #
      # @return [String]
      #
      # @api private
      NEWLINE = "\n"
      private_constant :NEWLINE

      # The space character
      #
      # @return [String]
      #
      # @api private
      SPACE = " "
      private_constant :SPACE

      def initialize(root, options = {})
        super
        @pastel = Pastel.new(enabled: options[:enabled])
        @color_opts = {
          color: @pastel.yellow.detach,
          enabled: options[:enabled],
          mode: options[:mode]
        }
        @current_indent = 0
        @footnote_no = 1
        @footnotes = {}
        @indent = options[:indent]
        @symbols = options[:symbols]
        @theme = options[:theme]
        @width = options[:width]
      end

      # Invoke an element conversion
      #
      # @api public
      def convert(el, opts = {indent: 0})
        send(:"convert_#{el.type}", el, opts)
      end

      private

      # Process children of this element
      #
      # @param [Kramdown::Element] el
      #   the element with child elements
      #
      # @api private
      def inner(el, opts)
        result = []
        last_child_index = el.children.length - 1
        el.children.each_with_index do |inner_el, i|
          options = opts.dup
          options[:parent] = el
          options[:prev] = (i.zero? ? nil : el.children[i - 1])
          options[:next] = (i == last_child_index ? nil : el.children[i + 1])
          options[:index] = i
          result << convert(inner_el, options)
        end
        result
      end

      # Convert root element
      #
      # @param [Kramdown::Element] el
      #   the `kd:root` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_root(el, opts)
        content = inner(el, opts)
        return content.join if @footnotes.empty?

        content.join + footnotes_list(root, opts)
      end

      # Create an ordered list of footnotes
      #
      # @param [Kramdown::Element] root
      #   the `kd:root` element
      # @param [Hash] opts
      #   the root element options
      #
      # @api private
      def footnotes_list(root, opts)
        ol = Kramdown::Element.new(:ol)
        @footnotes.each_value do |footnote|
          value, index = *footnote
          options = {index: index, parent: ol}
          li = Kramdown::Element.new(:li, nil, {}, options.merge(opts))
          li.children = Marshal.load(Marshal.dump(value.children))
          ol.children << li
        end
        convert_ol(ol, {parent: root}.merge(opts))
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
        styles = @theme[:header].dup
        styles << :underline if level == 1

        content = inner(el, opts)

        content.join.lines.map do |line|
          "#{indent}#{@pastel.decorate(line.chomp, *styles)}#{NEWLINE}"
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
        parent_type = opts[:parent].type
        result = []
        result << indent unless INDENTED_HTML_ELEMENTS.include?(parent_type)
        opts[:indent] = parent_type == :blockquote ? 0 : @current_indent

        content = inner(el, opts)

        result << content.join
        result << NEWLINE unless result.last.to_s.end_with?(NEWLINE)
        result
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
        text.gsub(NEWLINE, "#{NEWLINE}#{indent}")
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
        content = inner(el, opts)

        content.join.lines.map do |line|
          @pastel.decorate(line.chomp, *@theme[:strong])
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
        content = inner(el, opts)

        content.join.lines.map do |line|
          @pastel.decorate(line.chomp, *@theme[:em])
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
      def convert_blank(*)
        NEWLINE
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
        @symbols[el.value]
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
        indent = SPACE * @current_indent
        syntax_opts = @color_opts.merge(lang: el.options[:lang])
        raw_code = Strings.wrap(el.value, @width - @current_indent)
        highlighted = SyntaxHighliter.highlight(raw_code, **syntax_opts)

        highlighted.lines.map.with_index do |line, i|
          i.zero? ? line.chomp : indent + line.chomp
        end.join(NEWLINE)
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
        indent = SPACE * @current_indent
        "#{indent}#{convert_codespan(el, opts)}"
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
        prefix = "#{indent}#{@pastel.decorate(bar_symbol, *@theme[:quote])}  "

        content = inner(el, opts)

        content.join.lines.map do |line|
          "#{prefix}#{line}"
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
        content = inner(el, opts)
        @current_indent -= @indent unless opts[:parent].type == :root
        content.join
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
        indent = SPACE * @current_indent
        parent_type = opts[:parent].type
        prefix_type = parent_type == :ol ? "#{index}." : @symbols[:bullet]
        prefix = @pastel.decorate(prefix_type, *@theme[:list]) + SPACE
        opts[:strip] = true

        content = inner(el, opts)

        "#{indent}#{prefix}#{content.join}"
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
        indent = SPACE * @current_indent
        content = inner(el, opts)
        "#{indent}#{content.join}#{NEWLINE}"
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
        result = []
        @current_indent += @indent unless opts[:parent].type == :root
        content = inner(el, opts)
        @current_indent -= @indent unless opts[:parent].type == :root
        result << content.join
        result << NEWLINE if opts[:next] && opts[:next].type == :dt
        result
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
        table_data = extract_table_data(el, opts)
        opts[:table_data] = table_data
        opts[:column_widths] = distribute_widths(max_widths(table_data))
        opts[:row_heights] = max_row_heights(table_data, opts[:column_widths])

        inner(el, opts).join
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
            data << row.children.map do |cell|
              inner(cell, opts)
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
        screen_width = @width - ((indent.length + 1) * 2) - (widths.size + 1)
        return widths if total_width <= screen_width

        extra_width = total_width - screen_width

        widths.map do |width|
          ratio = width / total_width.to_f
          width - (extra_width * ratio).floor
        end
      end

      # Calculate maximum widths for each column
      #
      # @return [Array<Integer>]
      #
      # @api private
      def max_widths(table_data)
        table_data.first.each_with_index.reduce([]) do |widths, (_, col)|
          widths << max_width(table_data, col)
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
        table_data.reduce([]) do |heights, row|
          heights << max_row_height(row, column_widths)
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
        result = []

        result << indent
        result << border(opts[:column_widths], :top)
        result << NEWLINE

        content = inner(el, opts)

        result << content.join
        result.join
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
        result = []
        result << @symbols[:"#{location}_left"]
        column_widths.each.with_index do |width, i|
          result << @symbols[:"#{location}_center"] if i != 0
          result << (@symbols[:line] * (width + 2))
        end
        result << @symbols[:"#{location}_right"]
        @pastel.decorate(result.join, *@theme[:table])
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
        column_widths = opts[:column_widths]
        indent = SPACE * @current_indent
        next_type = opts[:next] && opts[:next].type
        prev_type = opts[:prev] && opts[:prev].type
        result = []

        result << indent
        result << border(column_widths, prev_type == :thead ? :mid : :top)
        result << NEWLINE

        content = inner(el, opts)

        result << content.join
        result << indent
        result << border(column_widths, next_type == :tfoot ? :mid : :bottom)
        result << NEWLINE
        result.join
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
        bottom_border = border(opts[:column_widths], :bottom)
        content = inner(el, opts)
        indent = SPACE * @current_indent

        "#{content.join}#{indent}#{bottom_border}#{NEWLINE}"
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
        result = []

        if opts[:prev] && opts[:prev].type == :tr
          result << indent
          result << border(opts[:column_widths], :mid)
          result << NEWLINE
        end

        content = inner(el, opts)

        result << format_table_row(content)
        @row += 1
        result.join
      end

      # Format table row
      #
      # @param [String] content
      #   the content to format
      #
      # @return [String]
      #
      # @api private
      def format_table_row(content)
        columns = content.count
        last_column_index = columns - 1
        content.each_with_object([]).with_index do |(cell, row), i|
          last_column = i == last_column_index
          if cell.size > 1 # multiline
            insert_multiline_cell_into_row(cell, last_column, row)
          else
            row << cell
            row << NEWLINE if last_column
          end
        end.join
      end

      # Insert multiline cell into row
      #
      # @param [Array<String>] cell
      #   the cell to insert
      # @param [Boolean] last_column
      #   whether the column is last or not
      # @param [Array] row
      #   the row to insert into
      #
      # @return [void]
      #
      # @api private
      def insert_multiline_cell_into_row(cell, last_column, row)
        cell.each_with_index do |cell_line, j| # zip columns
          row[j] = [] if row[j].nil?
          row[j] << cell_line.chomp
          row[j] << NEWLINE if last_column
        end
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
        pipe = @pastel.decorate(pipe_char, *@theme[:table])
        suffix = " #{pipe} "
        cell_content = inner(el, opts)
        formatted_cell = format_table_cell(cell_content, opts)
        content = formatted_cell.lines.map do |line|
          # add pipe to first column
          (@column.zero? ? "#{indent}#{pipe} " : EMPTY) +
            (line.end_with?(NEWLINE) ? line.insert(-2, suffix) : line << suffix)
        end
        @column = (@column + 1) % opts[:column_widths].size
        content
      end

      # Format table cell
      #
      # @param [String] content
      #   the content to format
      # @param [Hash] opts
      #   the element options
      #
      # @return [String]
      #
      # @api private
      def format_table_cell(content, opts)
        cell_width = opts[:column_widths][@column]
        cell_height = opts[:row_heights][@row]
        alignment = opts[:alignment][@column]
        align_opts = alignment == :default ? {} : {direction: alignment}

        wrapped = Strings.wrap(content.join, cell_width)
        aligned = Strings.align(wrapped, cell_width, **align_opts)
        if aligned.lines.size < cell_height
          Strings.pad(aligned, [0, 0, cell_height - aligned.lines.size, 0])
        else
          aligned.dup
        end
      end

      def convert_br(el, opts)
        NEWLINE
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
        width = @width - (@symbols[:diamond].length * 2)
        inner_line = @symbols[:line] * width
        line = "#{@symbols[:diamond]}#{inner_line}#{@symbols[:diamond]}"
        @pastel.decorate(line, *@theme[:hr]) + NEWLINE
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
        result = []

        if URI.parse(el.attr["href"]).instance_of?(URI::MailTo)
          el.attr["href"] = URI.parse(el.attr["href"]).to
        end

        if el.children.size == 1 && el.children[0].type == :text &&
           el.children[0].value == el.attr["href"]

          if !el.attr["title"].nil? && !el.attr["title"].strip.empty?
            result << "(#{el.attr["title"]}) "
          end
          result << @pastel.decorate(el.attr["href"], *@theme[:link])

        elsif el.children.any? && (el.children[0].type != :text ||
                                   !el.children[0].value.strip.empty?)

          content = inner(el, opts)

          result << content.join
          result << " #{@symbols[:arrow]} "
          result << "(#{el.attr["title"]}) " if el.attr["title"]
          result << @pastel.decorate(el.attr["href"], *@theme[:link])
        end
        result
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
          convert_codeblock(el, opts) + NEWLINE
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
        if title.to_s.empty?
          el.value
        else
          "#{el.value}(#{title})"
        end
      end

      def convert_typographic_sym(el, opts)
        @symbols[el.value]
      end

      def convert_entity(el, opts)
        unicode_char(el.value.code_point)
      end

      # Convert codepoint to UTF-8 representation
      def unicode_char(codepoint)
        [codepoint].pack("U*")
      end

      # Convert image element
      #
      # @param [Kramdown::Element] element
      #   the `kd:footnote` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_footnote(el, opts)
        name = el.options[:name]
        if (footnote = @footnotes[name])
          number = footnote.last
        else
          number = @footnote_no
          @footnote_no += 1
          @footnotes[name] = [el.value, number]
        end

        @pastel.decorate(
          "#{@symbols[:bracket_left]}#{number}#{@symbols[:bracket_right]}",
          *@theme[:note]
        )
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
        src = el.attr["src"]
        alt = el.attr["alt"]
        link = [@symbols[:paren_left]]
        link << "#{alt} #{@symbols[:ndash]} " unless alt.to_s.empty?
        link << "#{src}#{@symbols[:paren_right]}"
        @pastel.decorate(link.join, *@theme[:image])
      end

      # Convert html element
      #
      # @param [Kramdown::Element] element
      #   the `kd:html_element` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_html_element(el, opts)
        if el.value == "div"
          inner(el, opts)
        elsif %w[i em].include?(el.value)
          convert_em(el, opts)
        elsif %w[b strong].include?(el.value)
          convert_strong(el, opts)
        elsif el.value == "img"
          convert_img(el, opts)
        elsif el.value == "a"
          convert_a(el, opts)
        elsif el.value == "del"
          inner(el, opts).join.chars.to_a.map do |char|
            char + @symbols[:delete]
          end
        elsif el.value == "br"
          NEWLINE
        elsif el.children.any?
          inner(el, opts)
        else
          warning("HTML element '#{el.value.inspect}' not supported")
          EMPTY
        end
      end

      # Convert xml comment element
      #
      # @param [Kramdown::Element] element
      #   the `kd:xml_comment` element
      # @param [Hash] opts
      #   the element options
      #
      # @api private
      def convert_xml_comment(el, opts)
        block = el.options[:category] == :block
        indent = SPACE * @current_indent
        content = el.value
        content.gsub!(/^<!-{2,}\s*/, EMPTY) if content.start_with?("<!--")
        content.gsub!(/-{2,}>$/, EMPTY) if content.end_with?("-->")
        result = content.lines.map.with_index do |line, i|
          (i.zero? && !block ? EMPTY : indent) +
            @pastel.decorate("#{@symbols[:hash]} " + line.chomp,
                             *@theme[:comment])
        end.join(NEWLINE)
        block ? result + NEWLINE : result
      end
      alias convert_comment convert_xml_comment
    end # Parser
  end # Markdown
end # TTY
