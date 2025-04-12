# frozen_string_literal: true

require "kramdown/converter"
require "kramdown/element"
require "pastel"
require "strings"
require "uri"

require_relative "syntax_highlighter"

module TTY
  module Markdown
    # Responsible for converting a Markdown document into terminal output
    #
    # @api private
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

      # The UTF-8 characters directive
      #
      # @return [String]
      #
      # @api private
      UTF8_CHARACTERS_DIRECTIVE = "U*"
      private_constant :UTF8_CHARACTERS_DIRECTIVE

      # Create a {TTY::Markdown::Converter} instance
      #
      # @example
      #   converter = TTY::Markdown::Converter.new(document)
      #
      # @param [Kramdown::Element] root
      #   the root element
      # @param [Hash] options
      #   the root element options
      #
      # @api public
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

      # Convert an element
      #
      # @example
      #   converter.convert(root)
      #
      # @param [Kramdown::Element] element
      #   the root element
      # @param [Hash] options
      #   the root element options
      #
      # @return [String]
      #
      # @api public
      def convert(element, options = {indent: 0})
        send(:"convert_#{element.type}", element, options)
      end

      private

      # The available width without the current indentation
      #
      # @return [Integer]
      #
      # @api private
      def available_width
        @width - @current_indent
      end

      # Decorate each content line with styles
      #
      # @param [String] content
      #   the content to decorate
      # @param [Array<Symbol>] styles
      #   the styles to decorate with
      #
      # @return [String]
      #
      # @api private
      def decorate_each_line(content, styles)
        content.lines.map do |line|
          @pastel.decorate(line.chomp, *styles)
        end.join(NEWLINE)
      end

      # Indent content by the indentation level
      #
      # @param [Integer] indentation_level
      #   the indentation level
      #
      # @return [void]
      #
      # @api private
      def indent_by(indentation_level)
        @current_indent = indentation_level * @indent
      end

      # The current space indentation
      #
      # @return [String]
      #
      # @api private
      def indentation
        SPACE * @current_indent
      end

      # Invoke a block with indentation
      #
      # @param [Boolean] add_indentation
      #   whether to add indentation
      #
      # @return [Object]
      #
      # @api private
      def with_indentation(add_indentation: true)
        @current_indent += @indent if add_indentation
        yield.tap do
          @current_indent -= @indent if add_indentation
        end
      end

      # Transform an element children
      #
      # @param [Kramdown::Element] element
      #   the element with child elements
      # @param [Hash] options
      #   the element options
      #
      # @return [Array<String>]
      #
      # @api private
      def transform_children(element, options)
        element.children.map.with_index do |child_element, child_index|
          child_options = build_child_options(element, child_index)
          convert(child_element, options.merge(child_options))
        end
      end

      # Build a child element options
      #
      # @param [Kramdown::Element] element
      #   the element with child elements
      # @param [Integer] child_index
      #   the child element index
      #
      # @return [Hash]
      #
      # @api private
      def build_child_options(element, child_index)
        {
          index: child_index,
          next: element.children[child_index + 1],
          parent: element,
          prev: child_index > 0 ? element.children[child_index - 1] : nil
        }
      end

      # Convert a root element
      #
      # @param [Kramdown::Element] element
      #   the root element
      # @param [Hash] options
      #   the root element options
      #
      # @return [String]
      #
      # @api private
      def convert_root(element, options)
        content = transform_children(element, options)
        return content.join if @footnotes.empty?

        content.join + build_footnotes_list(root, options)
      end

      # Build an ordered list of footnotes
      #
      # @param [Kramdown::Element] root
      #   the root element
      # @param [Hash] options
      #   the root element options
      #
      # @return [String]
      #
      # @api private
      def build_footnotes_list(root, options)
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

      # Convert a header element
      #
      # @param [Kramdown::Element] element
      #   the header element
      # @param [Hash] options
      #   the header element options
      #
      # @return [Array<String>]
      #
      # @api private
      def convert_header(element, options)
        level = element.options[:level]
        indent_content = options[:parent].type == :root
        indent_by(level - 1) if indent_content
        styles = @theme[:header].dup
        styles << :underline if level == 1
        content = transform_children(element, options)
        content.join.lines.map do |line|
          "#{indentation}#{@pastel.decorate(line.chomp, *styles)}#{NEWLINE}"
        end
      end

      # Convert a paragraph element
      #
      # @param [Kramdown::Element] element
      #   the p element
      # @param [Hash] options
      #   the p element options
      #
      # @return [Array<String>]
      #
      # @api private
      def convert_p(element, options)
        parent_type = options[:parent].type
        indent_content = !INDENTED_HTML_ELEMENTS.include?(parent_type)
        options[:indent] = parent_type == :blockquote ? 0 : @current_indent
        content = transform_children(element, options)
        "#{indentation if indent_content}#{content.join}#{NEWLINE}"
      end

      # Convert a text element
      #
      # @param [Kramdown::Element] element
      #   the text element
      # @param [Hash] options
      #   the text element options
      #
      # @return [String]
      #
      # @api private
      def convert_text(element, options)
        text = Strings.wrap(element.value, available_width)
        text = text.chomp if options[:strip]
        indent = SPACE * options[:indent]
        text.gsub(NEWLINE, "#{NEWLINE}#{indent}")
      end

      # Convert a strong element
      #
      # @param [Kramdown::Element] element
      #   the strong element
      # @param [Hash] options
      #   the strong element options
      #
      # @return [String]
      #
      # @api private
      def convert_strong(element, options)
        content = transform_children(element, options)
        decorate_each_line(content.join, @theme[:strong])
      end

      # Convert an emphasis element
      #
      # @param [Kramdown::Element] element
      #   the em element
      # @param [Hash] options
      #   the em element options
      #
      # @return [String]
      #
      # @api private
      def convert_em(element, options)
        content = transform_children(element, options)
        decorate_each_line(content.join, @theme[:em])
      end

      # Convert a blank element
      #
      # @return [String]
      #
      # @api private
      def convert_blank(*)
        NEWLINE
      end

      # Convert a smart quote element
      #
      # @param [Kramdown::Element] element
      #   the smart quote element
      # @param [Hash] options
      #   the smart quote element options
      #
      # @return [String]
      #
      # @api private
      def convert_smart_quote(element, options)
        @symbols[element.value]
      end

      # Convert a codespan element
      #
      # @param [Kramdown::Element] element
      #   the codespan element
      # @param [Hash] options
      #   the codespan element options
      #
      # @return [String]
      #
      # @api private
      def convert_codespan(element, options)
        highlighter_options = @color_options.merge(lang: element.options[:lang])
        code = Strings.wrap(element.value, available_width)
        highlighted = SyntaxHighliter.highlight(code, **highlighter_options)
        highlighted.lines.map.with_index do |line, line_index|
          "#{indentation unless line_index.zero?}#{line.chomp}"
        end.join(NEWLINE)
      end

      # Convert a codeblock element
      #
      # @param [Kramdown::Element] element
      #   the codeblock element
      # @param [Hash] options
      #   the codeblock element options
      #
      # @return [String]
      #
      # @api private
      def convert_codeblock(element, options)
        "#{indentation}#{convert_codespan(element, options)}"
      end

      # Convert a blockquote element
      #
      # @param [Kramdown::Element] element
      #   the blockquote element
      # @param [Hash] options
      #   the blockquote element options
      #
      # @return [Array<String>]
      #
      # @api private
      def convert_blockquote(element, options)
        bar = @pastel.decorate(@symbols[:bar], *@theme[:quote])
        prefix = "#{indentation}#{bar}  "
        content = transform_children(element, options)
        content.join.lines.map do |line|
          "#{prefix}#{line}"
        end
      end

      # Convert a description, ordered or unordered list element
      #
      # @param [Kramdown::Element] element
      #   the dl, ol or ul element
      # @param [Hash] options
      #   the dl, ol or ul element options
      #
      # @return [String]
      #
      # @api private
      def convert_ul(element, options)
        indent_content = options[:parent].type != :root
        content = with_indentation(add_indentation: indent_content) do
          transform_children(element, options)
        end
        content.join
      end
      alias convert_ol convert_ul
      alias convert_dl convert_ul

      # Convert a list item element
      #
      # @param [Kramdown::Element] element
      #   the li element
      # @param [Hash] options
      #   the li element options
      #
      # @return [String]
      #
      # @api private
      def convert_li(element, options)
        index = options[:index] + 1
        parent_type = options[:parent].type
        prefix_type = parent_type == :ol ? "#{index}." : @symbols[:bullet]
        prefix = "#{@pastel.decorate(prefix_type, *@theme[:list])} "
        options[:strip] = true
        content = transform_children(element, options)
        "#{indentation}#{prefix}#{content.join}"
      end

      # Convert a description term element
      #
      # @param [Kramdown::Element] element
      #   the dt element
      # @param [Hash] options
      #   the dt element options
      #
      # @return [String]
      #
      # @api private
      def convert_dt(element, options)
        content = transform_children(element, options)
        "#{indentation}#{content.join}#{NEWLINE}"
      end

      # Convert a description details element
      #
      # @param [Kramdown::Element] element
      #   the dd element
      # @param [Hash] options
      #   the dd element options
      #
      # @return [Array<String>]
      #
      # @api private
      def convert_dd(element, options)
        next_type = options[:next] && options[:next].type
        suffix = next_type == :dt ? NEWLINE : EMPTY
        content = with_indentation do
          transform_children(element, options)
        end
        "#{content.join}#{suffix}"
      end

      # Convert a table element
      #
      # @param [Kramdown::Element] element
      #   the table element
      # @param [Hash] options
      #   the table element options
      #
      # @return [String]
      #
      # @api private
      def convert_table(element, options)
        initialize_table
        table_data = extract_table_data(element, options)
        max_column_widths = calculate_max_column_widths(table_data)
        column_widths = distribute_column_widths(max_column_widths)
        row_heights = calculate_max_row_heights(table_data, column_widths)
        options[:alignment] = element.options[:alignment]
        options[:column_widths] = column_widths
        options[:row_heights] = row_heights
        options[:table_data] = table_data
        transform_children(element, options).join
      end

      # Initialise a table
      #
      # @return [void]
      #
      # @api private
      def initialize_table
        @column = 0
        @row = 0
      end

      # Extract the table data
      #
      # @param [Kramdown::Element] element
      #   the table element
      # @param [Hash] options
      #   the table element options
      #
      # @return [Array<Array<String>>]
      #
      # @api private
      def extract_table_data(element, options)
        element.children.each_with_object([]) do |child_element, data|
          child_element.children.each do |row|
            data << row.children.map do |cell|
              transform_children(cell, options)
            end
          end
        end
      end

      # Distribute column widths within the total width
      #
      # @param [Array<Integer>] column_widths
      #   the table column widths
      #
      # @return [Array<Integer>]
      #
      # @api private
      def distribute_column_widths(column_widths)
        borders_width = (column_widths.size + 1)
        indentation_width = (indentation.length + 1) * 2
        screen_width = @width - borders_width - indentation_width
        total_width = column_widths.reduce(&:+)
        return column_widths if total_width <= screen_width

        extra_width = total_width - screen_width
        column_widths.map do |column_width|
          ratio = column_width / total_width.to_f
          column_width - (extra_width * ratio).floor
        end
      end

      # Calculate maximum widths for every column
      #
      # @param [Array<Array<String>>] table_data
      #   the table data
      #
      # @return [Array<Integer>]
      #
      # @api private
      def calculate_max_column_widths(table_data)
        table_data.first.map.with_index do |_, column_index|
          calculate_max_column_width(table_data, column_index)
        end
      end

      # Calculate the maximum table cell width for a given column index
      #
      # @param [Array<Array<String>>] table_data
      #   the table data
      # @param [Integer] column_index
      #   the table column index
      #
      # @return [Integer]
      #
      # @api private
      def calculate_max_column_width(table_data, column_index)
        table_data.map do |row|
          Strings.sanitize(row[column_index].join).lines.map(&:length).max || 0
        end.max
      end

      # Calculate maximum heights for every row
      #
      # @param [Array<Array<String>>] table_data
      #   the table data
      # @param [Array<Integer>] column_widths
      #   the table column widths
      #
      # @return [Array<Integer>]
      #
      # @api private
      def calculate_max_row_heights(table_data, column_widths)
        table_data.map do |row|
          calculate_max_row_height(row, column_widths)
        end
      end

      # Calculate the maximum table cell height for a given row
      #
      # @param [Array<Array<String>>] row
      #   the table row
      # @param [Array<Integer>] column_widths
      #   the table column widths
      #
      # @return [Integer]
      #
      # @api private
      def calculate_max_row_height(row, column_widths)
        row.map.with_index do |cell, column_index|
          Strings.wrap(cell.join, column_widths[column_index]).lines.size
        end.max
      end

      # Convert a table head element
      #
      # @param [Kramdown::Element] element
      #   the thead element
      # @param [Hash] options
      #   the thead element options
      #
      # @return [String]
      #
      # @api private
      def convert_thead(element, options)
        top_border = build_border(options[:column_widths], :top)
        content = transform_children(element, options)
        "#{indentation}#{top_border}#{NEWLINE}#{content.join}"
      end

      # Build a horizontal border line
      #
      # @param [Array<Integer>] column_widths
      #   the table column widths
      # @param [Symbol] location
      #   location out of :top, :mid, :bottom
      #
      # @return [String]
      #
      # @api private
      def build_border(column_widths, location)
        border = [@symbols[:"#{location}_left"]]
        column_widths.each.with_index do |column_width, column_index|
          border << @symbols[:"#{location}_center"] unless column_index.zero?
          border << (@symbols[:line] * (column_width + 2))
        end
        border << @symbols[:"#{location}_right"]
        @pastel.decorate(border.join, *@theme[:table])
      end

      # Convert a table body element
      #
      # @param [Kramdown::Element] element
      #   the tbody element
      # @param [Hash] options
      #   the tbody element options
      #
      # @return [String]
      #
      # @api private
      def convert_tbody(element, options)
        column_widths = options[:column_widths]
        next_type = options[:next] && options[:next].type
        prev_type = options[:prev] && options[:prev].type
        top_border_type = prev_type == :thead ? :mid : :top
        top_border = build_border(column_widths, top_border_type)
        bottom_border_type = next_type == :tfoot ? :mid : :bottom
        bottom_border = build_border(column_widths, bottom_border_type)
        content = transform_children(element, options)
        "#{indentation}#{top_border}#{NEWLINE}#{content.join}" \
          "#{indentation}#{bottom_border}#{NEWLINE}"
      end

      # Convert a table foot element
      #
      # @param [Kramdown::Element] element
      #   the tfoot element
      # @param [Hash] options
      #   the tfoot element options
      #
      # @return [String]
      #
      # @api private
      def convert_tfoot(element, options)
        bottom_border = build_border(options[:column_widths], :bottom)
        content = transform_children(element, options)
        "#{content.join}#{indentation}#{bottom_border}#{NEWLINE}"
      end

      # Convert a table row element
      #
      # @param [Kramdown::Element] element
      #   the tr element
      # @param [Hash] options
      #   the tr element options
      #
      # @return [String]
      #
      # @api private
      def convert_tr(element, options)
        border = EMPTY

        if options[:prev] && options[:prev].type == :tr
          middle_border = build_border(options[:column_widths], :mid)
          border = "#{indentation}#{middle_border}#{NEWLINE}"
        end

        content = transform_children(element, options)
        @row += 1
        "#{border}#{format_table_row(content)}"
      end

      # Format a table row
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
          append_newline = column_index == last_column_index
          insert_cell_into_row(cell, row, append_newline)
        end.join
      end

      # Insert a cell into a table row
      #
      # @param [Array<String>] cell
      #   the cell to insert
      # @param [Array] row
      #   the row to insert into
      # @param [Boolean] append_newline
      #   whether to append a newline
      #
      # @return [void]
      #
      # @api private
      def insert_cell_into_row(cell, row, append_newline)
        cell.each_with_index do |cell_line, cell_line_index|
          (row[cell_line_index] ||= []) << cell_line.chomp
          row[cell_line_index] << NEWLINE if append_newline
        end
      end

      # Convert a table data element
      #
      # @param [Kramdown::Element] element
      #   the td element
      # @param [Hash] options
      #   the td element options
      #
      # @return [Array<String>]
      #
      # @api private
      def convert_td(element, options)
        pipe = @pastel.decorate(@symbols[:pipe], *@theme[:table])
        prefix = @column.zero? ? "#{indentation}#{pipe} " : EMPTY
        suffix = " #{pipe} "
        cell_content = transform_children(element, options)
        formatted_cell = format_table_cell(cell_content, options)
        @column = (@column + 1) % options[:column_widths].size
        formatted_cell.lines.map do |line|
          suffix_insert_index = line.end_with?(NEWLINE) ? -2 : -1
          "#{prefix}#{line.insert(suffix_insert_index, suffix)}"
        end
      end

      # Format a table cell
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

      # Convert a line break element
      #
      # @param [Kramdown::Element] element
      #   the br element
      # @param [Hash] options
      #   the br element options
      #
      # @return [String]
      #
      # @api private
      def convert_br(element, options)
        NEWLINE
      end

      # Convert a horizontal rule element
      #
      # @param [Kramdown::Element] element
      #   the hr element
      # @param [Hash] options
      #   the hr element options
      #
      # @return [String]
      #
      # @api private
      def convert_hr(element, options)
        width = @width - (@symbols[:diamond].length * 2)
        inner_line = @symbols[:line] * width
        line = "#{@symbols[:diamond]}#{inner_line}#{@symbols[:diamond]}"
        "#{@pastel.decorate(line, *@theme[:hr])}#{NEWLINE}"
      end

      # Convert an anchor element
      #
      # @param [Kramdown::Element] element
      #   the a element
      # @param [Hash] options
      #   the a element options
      #
      # @return [Array<String>]
      #
      # @api private
      def convert_a(element, options)
        attributes = element.attr
        children = element.children
        link = []

        if URI.parse(attributes["href"]).instance_of?(URI::MailTo)
          attributes["href"] = URI.parse(attributes["href"]).to
        end

        if children.size == 1 && children[0].type == :text &&
           children[0].value == attributes["href"]

          if !attributes["title"].nil? && !attributes["title"].strip.empty?
            link << "(#{attributes["title"]}) "
          end
          link << @pastel.decorate(attributes["href"], *@theme[:link])

        elsif children.any? && (children[0].type != :text ||
                                !children[0].value.strip.empty?)

          content = transform_children(element, options)

          link << content.join
          link << " #{@symbols[:arrow]} "
          link << "(#{attributes["title"]}) " if attributes["title"]
          link << @pastel.decorate(attributes["href"], *@theme[:link])
        end
        link
      end

      # Convert a math element
      #
      # @param [Kramdown::Element] element
      #   the math element
      # @param [Hash] options
      #   the math element options
      #
      # @return [String]
      #
      # @api private
      def convert_math(element, options)
        if element.options[:category] == :block
          convert_codeblock(element, options) + NEWLINE
        else
          convert_codespan(element, options)
        end
      end

      # Convert an abbreviation element
      #
      # @param [Kramdown::Element] element
      #   the abbreviation element
      # @param [Hash] options
      #   the abbreviation element options
      #
      # @return [String]
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

      # Convert a typographic symbol element
      #
      # @param [Kramdown::Element] element
      #   the typographic sym element
      # @param [Hash] options
      #   the typographic sym element options
      #
      # @return [String]
      #
      # @api private
      def convert_typographic_sym(element, options)
        @symbols[element.value]
      end

      # Convert an entity element
      #
      # @param [Kramdown::Element] element
      #   the entity element
      # @param [Hash] options
      #   the entity element options
      #
      # @return [String]
      #
      # @api private
      def convert_entity(element, options)
        transform_codepoint(element.value.code_point)
      end

      # Transform a codepoint into a UTF-8 character
      #
      # @param [Integer] codepoint
      #   the codepoint to transform
      #
      # @return [String]
      #
      # @api private
      def transform_codepoint(codepoint)
        [codepoint].pack(UTF8_CHARACTERS_DIRECTIVE)
      end

      # Convert a footnote element
      #
      # @param [Kramdown::Element] element
      #   the footnote element
      # @param [Hash] options
      #   the footnote element options
      #
      # @return [String]
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

      # Convert a raw element
      #
      # @return [String]
      #
      # @api private
      def convert_raw(*)
        warning("Raw content is not supported")
      end

      # Convert an image element
      #
      # @param [Kramdown::Element] element
      #   the img element
      # @param [Hash] options
      #   the img element options
      #
      # @return [String]
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

      # Convert an HTML element
      #
      # @param [Kramdown::Element] element
      #   the html element
      # @param [Hash] options
      #   the html element options
      #
      # @return [Array<String>, String]
      #
      # @api private
      def convert_html_element(element, options)
        if element.value == "div"
          transform_children(element, options)
        elsif %w[i em].include?(element.value)
          convert_em(element, options)
        elsif %w[b strong].include?(element.value)
          convert_strong(element, options)
        elsif element.value == "img"
          convert_img(element, options)
        elsif element.value == "a"
          convert_a(element, options)
        elsif element.value == "del"
          transform_children(element, options).join.chars.to_a.map do |char|
            char + @symbols[:delete]
          end
        elsif element.value == "br"
          NEWLINE
        elsif element.children.any?
          transform_children(element, options)
        else
          warning("HTML element '#{element.value.inspect}' not supported")
          EMPTY
        end
      end

      # Convert an XML comment element
      #
      # @param [Kramdown::Element] element
      #   the xml comment element
      # @param [Hash] options
      #   the xml comment element options
      #
      # @return [String]
      #
      # @api private
      def convert_xml_comment(element, options)
        inline_level = element.options[:category] == :span
        content = element.value
        content.gsub!(/^<!-{2,}\s*/, EMPTY) if content.start_with?("<!--")
        content.gsub!(/-{2,}>$/, EMPTY) if content.end_with?("-->")
        comment = content.lines.map.with_index do |line, line_index|
          (line_index.zero? && inline_level ? EMPTY : indentation) +
            @pastel.decorate("#{@symbols[:hash]} #{line.chomp}",
                             *@theme[:comment])
        end.join(NEWLINE)
        inline_level ? comment : "#{comment}#{NEWLINE}"
      end
      alias convert_comment convert_xml_comment
    end # Parser
  end # Markdown
end # TTY
