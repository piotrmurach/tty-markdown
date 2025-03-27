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
        @color_options = {
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
      def convert(element, options = {indent: 0})
        send(:"convert_#{element.type}", element, options)
      end

      private

      # Process children of this element
      #
      # @param [Kramdown::Element] element
      #   the element with child elements
      #
      # @api private
      def inner(element, options)
        children = element.children
        last_child_index = children.length - 1
        children.map.with_index do |inner_element, i|
          options_copy = options.dup
          options_copy[:parent] = element
          options_copy[:prev] = (i.zero? ? nil : children[i - 1])
          options_copy[:next] = (i == last_child_index ? nil : children[i + 1])
          options_copy[:index] = i
          convert(inner_element, options_copy)
        end
      end

      # Convert root element
      #
      # @param [Kramdown::Element] element
      #   the `kd:root` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_root(element, options)
        content = inner(element, options)
        return content.join if @footnotes.empty?

        content.join + footnotes_list(root, options)
      end

      # Create an ordered list of footnotes
      #
      # @param [Kramdown::Element] root
      #   the `kd:root` element
      # @param [Hash] options
      #   the root element options
      #
      # @api private
      def footnotes_list(root, options)
        ol = Kramdown::Element.new(:ol)
        @footnotes.each_value do |footnote|
          value, index = *footnote
          li_options = {index: index, parent: ol}.merge(options)
          li = Kramdown::Element.new(:li, nil, {}, li_options)
          li.children = Marshal.load(Marshal.dump(value.children))
          ol.children << li
        end
        convert_ol(ol, {parent: root}.merge(options))
      end

      # Convert header element
      #
      # @param [Kramdown::Element] element
      #   the `kd:header` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_header(element, options)
        level = element.options[:level]
        if options[:parent] && options[:parent].type == :root
          # Header determines indentation only at top level
          @current_indent = (level - 1) * @indent
          indent = SPACE * (level - 1) * @indent
        else
          indent = SPACE * @current_indent
        end
        styles = @theme[:header].dup
        styles << :underline if level == 1

        content = inner(element, options)

        content.join.lines.map do |line|
          "#{indent}#{@pastel.decorate(line.chomp, *styles)}#{NEWLINE}"
        end
      end

      # Convert paragraph element
      #
      # @param [Kramdown::Element] element
      #   the `kd:p` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_p(element, options)
        indent = SPACE * @current_indent
        parent_type = options[:parent].type
        result = []
        result << indent unless INDENTED_HTML_ELEMENTS.include?(parent_type)
        options[:indent] = parent_type == :blockquote ? 0 : @current_indent

        content = inner(element, options)

        result << content.join
        result << NEWLINE unless result.last.to_s.end_with?(NEWLINE)
        result
      end

      # Convert text element
      #
      # @param [Kramdown::Element] element
      #   the `kd:text` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_text(element, options)
        text = Strings.wrap(element.value, @width - @current_indent)
        text = text.chomp if options[:strip]
        indent = SPACE * options[:indent]
        text.gsub(NEWLINE, "#{NEWLINE}#{indent}")
      end

      # Convert strong element
      #
      # @param [Kramdown::Element] element
      #   the `kd:strong` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_strong(element, options)
        content = inner(element, options)
        content.join.lines.map do |line|
          @pastel.decorate(line.chomp, *@theme[:strong])
        end.join(NEWLINE)
      end

      # Convert em element
      #
      # @param [Kramdown::Element] element
      #   the `kd:em` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_em(element, options)
        content = inner(element, options)
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
      # @param [Kramdown::Element] element
      #   the `kd:smart_quote` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_smart_quote(element, options)
        @symbols[element.value]
      end

      # Convert codespan element
      #
      # @param [Kramdown::Element] element
      #   the `kd:codespan` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_codespan(element, options)
        indent = SPACE * @current_indent
        highlighter_options = @color_options.merge(lang: element.options[:lang])
        raw_code = Strings.wrap(element.value, @width - @current_indent)
        highlighted = SyntaxHighliter.highlight(raw_code, **highlighter_options)
        highlighted.lines.map.with_index do |line, i|
          "#{indent unless i.zero?}#{line.chomp}"
        end.join(NEWLINE)
      end

      # Convert codeblock element
      #
      # @param [Kramdown::Element] element
      #   the `kd:codeblock` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_codeblock(element, options)
        indent = SPACE * @current_indent
        "#{indent}#{convert_codespan(element, options)}"
      end

      # Convert blockquote element
      #
      # @param [Kramdown::Element] element
      #   the `kd:blockquote` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_blockquote(element, options)
        indent = SPACE * @current_indent
        bar_symbol = @symbols[:bar]
        prefix = "#{indent}#{@pastel.decorate(bar_symbol, *@theme[:quote])}  "
        content = inner(element, options)
        content.join.lines.map do |line|
          "#{prefix}#{line}"
        end
      end

      # Convert ordered and unordered list element
      #
      # @param [Kramdown::Element] element
      #   the `kd:ul` or `kd:ol` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_ul(element, options)
        root_parent = options[:parent].type == :root
        @current_indent += @indent unless root_parent
        content = inner(element, options)
        @current_indent -= @indent unless root_parent
        content.join
      end
      alias convert_ol convert_ul
      alias convert_dl convert_ul

      # Convert list element
      #
      # @param [Kramdown::Element] element
      #   the `kd:li` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_li(element, options)
        index = options[:index] + 1
        indent = SPACE * @current_indent
        parent_type = options[:parent].type
        prefix_type = parent_type == :ol ? "#{index}." : @symbols[:bullet]
        prefix = @pastel.decorate(prefix_type, *@theme[:list]) + SPACE
        options[:strip] = true
        content = inner(element, options)
        "#{indent}#{prefix}#{content.join}"
      end

      # Convert dt element
      #
      # @param [Kramdown::Element] element
      #   the `kd:dt` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_dt(element, options)
        indent = SPACE * @current_indent
        content = inner(element, options)
        "#{indent}#{content.join}#{NEWLINE}"
      end

      # Convert dd element
      #
      # @param [Kramdown::Element] element
      #   the `kd:dd` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_dd(element, options)
        next_type = options[:next] && options[:next].type
        root_parent = options[:parent].type == :root
        suffix = next_type == :dt ? NEWLINE : EMPTY
        @current_indent += @indent unless root_parent
        content = inner(element, options)
        @current_indent -= @indent unless root_parent
        "#{content.join}#{suffix}"
      end

      # Convert table element
      #
      # @param [Kramdown::Element] element
      #   the `kd:table` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_table(element, options)
        @row = 0
        @column = 0
        table_data = extract_table_data(element, options)
        column_widths = distribute_column_widths(max_column_widths(table_data))
        options[:alignment] = element.options[:alignment]
        options[:column_widths] = column_widths
        options[:row_heights] = max_row_heights(table_data, column_widths)
        options[:table_data] = table_data
        inner(element, options).join
      end

      # Extract table data
      #
      # @param [Kramdown::Element] element
      #   the `kd:table` element
      #
      # @api private
      def extract_table_data(element, options)
        element.children.each_with_object([]) do |inner_element, data|
          inner_element.children.each do |row|
            data << row.children.map do |cell|
              inner(cell, options)
            end
          end
        end
      end

      # Distribute column widths inside total width
      #
      # @return [Array<Integer>]
      #
      # @api private
      def distribute_column_widths(column_widths)
        indent = SPACE * @current_indent
        indent_width = (indent.length + 1) * 2
        screen_width = @width - indent_width - (column_widths.size + 1)
        total_width = column_widths.reduce(&:+)
        return column_widths if total_width <= screen_width

        extra_width = total_width - screen_width
        column_widths.map do |column_width|
          ratio = column_width / total_width.to_f
          column_width - (extra_width * ratio).floor
        end
      end

      # Calculate maximum widths for each column
      #
      # @return [Array<Integer>]
      #
      # @api private
      def max_column_widths(table_data)
        table_data.first.map.with_index do |_, column_index|
          max_column_width(table_data, column_index)
        end
      end

      # Calculate maximum cell width for a given column
      #
      # @return [Integer]
      #
      # @api private
      def max_column_width(table_data, column_index)
        table_data.map do |row|
          Strings.sanitize(row[column_index].join).lines.map(&:length).max || 0
        end.max
      end

      # Calculate maximum heights for each row
      #
      # @return [Array<Integer>]
      #
      # @api private
      def max_row_heights(table_data, column_widths)
        table_data.map do |row|
          max_row_height(row, column_widths)
        end
      end

      # Calculate maximum cell height for a given row
      #
      # @return [Integer]
      #
      # @api private
      def max_row_height(row, column_widths)
        row.map.with_index do |cell, column_index|
          Strings.wrap(cell.join, column_widths[column_index]).lines.size
        end.max
      end

      # Convert thead element
      #
      # @param [Kramdown::Element] element
      #   the `kd:thead` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_thead(element, options)
        indent = SPACE * @current_indent
        top_border = border(options[:column_widths], :top)
        content = inner(element, options)
        "#{indent}#{top_border}#{NEWLINE}#{content.join}"
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
        result = [@symbols[:"#{location}_left"]]
        column_widths.each.with_index do |column_width, column_index|
          result << @symbols[:"#{location}_center"] if column_index != 0
          result << (@symbols[:line] * (column_width + 2))
        end
        result << @symbols[:"#{location}_right"]
        @pastel.decorate(result.join, *@theme[:table])
      end

      # Convert tbody element
      #
      # @param [Kramdown::Element] element
      #   the `kd:tbody` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_tbody(element, options)
        column_widths = options[:column_widths]
        indent = SPACE * @current_indent
        next_type = options[:next] && options[:next].type
        prev_type = options[:prev] && options[:prev].type
        top_border_type = prev_type == :thead ? :mid : :top
        top_border = border(column_widths, top_border_type)
        bottom_border_type = next_type == :tfoot ? :mid : :bottom
        bottom_border = border(column_widths, bottom_border_type)

        content = inner(element, options)

        "#{indent}#{top_border}#{NEWLINE}#{content.join}" \
          "#{indent}#{bottom_border}#{NEWLINE}"
      end

      # Convert tfoot element
      #
      # @param [Kramdown::Element] element
      #   the `kd:tfoot` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_tfoot(element, options)
        bottom_border = border(options[:column_widths], :bottom)
        content = inner(element, options)
        indent = SPACE * @current_indent

        "#{content.join}#{indent}#{bottom_border}#{NEWLINE}"
      end

      # Convert td element
      #
      # @param [Kramdown::Element] element
      #   the `kd:td` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_tr(element, options)
        border = EMPTY
        indent = SPACE * @current_indent

        if options[:prev] && options[:prev].type == :tr
          middle_border = border(options[:column_widths], :mid)
          border = "#{indent}#{middle_border}#{NEWLINE}"
        end

        content = inner(element, options)
        @row += 1
        "#{border}#{format_table_row(content)}"
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
        number_of_columns = content.size
        last_column_index = number_of_columns - 1
        content.each_with_object([]).with_index do |(cell, row), column_index|
          last_column = column_index == last_column_index
          if cell.size > 1
            insert_multiline_cell_into_row(cell, row, last_column)
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
      # @param [Array] row
      #   the row to insert into
      # @param [Boolean] last_column
      #   whether the column is last or not
      #
      # @return [void]
      #
      # @api private
      def insert_multiline_cell_into_row(cell, row, last_column)
        cell.each_with_index do |cell_line, row_index|
          row[row_index] = [] if row[row_index].nil?
          row[row_index] << cell_line.chomp
          row[row_index] << NEWLINE if last_column
        end
      end

      # Convert td element
      #
      # @param [Kramdown::Element] element
      #   the `kd:td` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_td(element, options)
        indent = SPACE * @current_indent
        pipe = @pastel.decorate(@symbols[:pipe], *@theme[:table])
        prefix = @column.zero? ? "#{indent}#{pipe} " : EMPTY
        suffix = " #{pipe} "
        cell_content = inner(element, options)
        formatted_cell = format_table_cell(cell_content, options)
        @column = (@column + 1) % options[:column_widths].size
        formatted_cell.lines.map do |line|
          suffix_insert_index = line.end_with?(NEWLINE) ? -2 : -1
          "#{prefix}#{line.insert(suffix_insert_index, suffix)}"
        end
      end

      # Format table cell
      #
      # @param [String] content
      #   the content to format
      # @param [Hash] options
      #   the element options
      #
      # @return [String]
      #
      # @api private
      def format_table_cell(content, options)
        alignment = options[:alignment][@column]
        align_options = alignment == :default ? {} : {direction: alignment}
        cell_height = options[:row_heights][@row]
        cell_width = options[:column_widths][@column]

        wrapped = Strings.wrap(content.join, cell_width)
        aligned = Strings.align(wrapped, cell_width, **align_options)
        if aligned.lines.size < cell_height
          Strings.pad(aligned, [0, 0, cell_height - aligned.lines.size, 0])
        else
          aligned.dup
        end
      end

      def convert_br(element, options)
        NEWLINE
      end

      # Convert hr element
      #
      # @param [Kramdown::Element] element
      #   the `kd:hr` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_hr(element, options)
        width = @width - (@symbols[:diamond].length * 2)
        inner_line = @symbols[:line] * width
        line = "#{@symbols[:diamond]}#{inner_line}#{@symbols[:diamond]}"
        "#{@pastel.decorate(line, *@theme[:hr])}#{NEWLINE}"
      end

      # Convert a element
      #
      # @param [Kramdown::Element] element
      #   the `kd:a` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_a(element, options)
        attributes = element.attr
        children = element.children
        result = []

        if URI.parse(attributes["href"]).instance_of?(URI::MailTo)
          attributes["href"] = URI.parse(attributes["href"]).to
        end

        if children.size == 1 && children[0].type == :text &&
           children[0].value == attributes["href"]

          if !attributes["title"].nil? && !attributes["title"].strip.empty?
            result << "(#{attributes["title"]}) "
          end
          result << @pastel.decorate(attributes["href"], *@theme[:link])

        elsif children.any? && (children[0].type != :text ||
                                !children[0].value.strip.empty?)

          content = inner(element, options)

          result << content.join
          result << " #{@symbols[:arrow]} "
          result << "(#{attributes["title"]}) " if attributes["title"]
          result << @pastel.decorate(attributes["href"], *@theme[:link])
        end
        result
      end

      # Convert math element
      #
      # @param [Kramdown::Element] element
      #   the `kd:math` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_math(element, options)
        if element.options[:category] == :block
          convert_codeblock(element, options) + NEWLINE
        else
          convert_codespan(element, options)
        end
      end

      # Convert abbreviation element
      #
      # @param [Kramdown::Element] element
      #   the `kd:abbreviation` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_abbreviation(element, options)
        title = @root.options[:abbrev_defs][element.value]
        if title.to_s.empty?
          element.value
        else
          "#{element.value}(#{title})"
        end
      end

      def convert_typographic_sym(element, options)
        @symbols[element.value]
      end

      def convert_entity(element, options)
        unicode_char(element.value.code_point)
      end

      # Convert codepoint to UTF-8 representation
      def unicode_char(codepoint)
        [codepoint].pack("U*")
      end

      # Convert image element
      #
      # @param [Kramdown::Element] element
      #   the `kd:footnote` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_footnote(element, options)
        name = element.options[:name]
        if (footnote = @footnotes[name])
          number = footnote.last
        else
          number = @footnote_no
          @footnote_no += 1
          @footnotes[name] = [element.value, number]
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
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_img(element, options)
        alt = element.attr["alt"]
        src = element.attr["src"]
        link = [@symbols[:paren_left]]
        link << "#{alt} #{@symbols[:ndash]} " unless alt.to_s.empty?
        link << "#{src}#{@symbols[:paren_right]}"
        @pastel.decorate(link.join, *@theme[:image])
      end

      # Convert html element
      #
      # @param [Kramdown::Element] element
      #   the `kd:html_element` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_html_element(element, options)
        if element.value == "div"
          inner(element, options)
        elsif %w[i em].include?(element.value)
          convert_em(element, options)
        elsif %w[b strong].include?(element.value)
          convert_strong(element, options)
        elsif element.value == "img"
          convert_img(element, options)
        elsif element.value == "a"
          convert_a(element, options)
        elsif element.value == "del"
          inner(element, options).join.chars.to_a.map do |char|
            char + @symbols[:delete]
          end
        elsif element.value == "br"
          NEWLINE
        elsif element.children.any?
          inner(element, options)
        else
          warning("HTML element '#{element.value.inspect}' not supported")
          EMPTY
        end
      end

      # Convert xml comment element
      #
      # @param [Kramdown::Element] element
      #   the `kd:xml_comment` element
      # @param [Hash] options
      #   the element options
      #
      # @api private
      def convert_xml_comment(element, options)
        block = element.options[:category] == :block
        indent = SPACE * @current_indent
        content = element.value
        content.gsub!(/^<!-{2,}\s*/, EMPTY) if content.start_with?("<!--")
        content.gsub!(/-{2,}>$/, EMPTY) if content.end_with?("-->")
        result = content.lines.map.with_index do |line, i|
          (i.zero? && !block ? EMPTY : indent) +
            @pastel.decorate("#{@symbols[:hash]} #{line.chomp}",
                             *@theme[:comment])
        end.join(NEWLINE)
        block ? result + NEWLINE : result
      end
      alias convert_comment convert_xml_comment
    end # Parser
  end # Markdown
end # TTY
