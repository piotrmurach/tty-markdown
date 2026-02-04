# frozen_string_literal: true

require "kramdown/converter/base"
require "pastel"
require "strings"

require_relative "decorator"
require_relative "highlighter"

module TTY
  class Markdown
    # Responsible for converting a Markdown document into terminal output
    #
    # @api private
    class Converter < ::Kramdown::Converter::Base
      # The alt attribute name
      #
      # @return [String]
      #
      # @api private
      ALT_ATTRIBUTE = "alt"
      private_constant :ALT_ATTRIBUTE

      # The HTML comment delimiters pattern
      #
      # @return [Regexp]
      #
      # @api private
      COMMENT_DELIMITERS_PATTERN = /^<!-{2,}\s*|-{2,}>$/.freeze
      private_constant :COMMENT_DELIMITERS_PATTERN

      # The converted HTML elements
      #
      # @return [Array<String>]
      #
      # @api private
      CONVERTED_HTML_ELEMENTS = %w[a b br del em i img strong].freeze
      private_constant :CONVERTED_HTML_ELEMENTS

      # The empty string
      #
      # @return [String]
      #
      # @api private
      EMPTY = ""
      private_constant :EMPTY

      # The href attribute name
      #
      # @return [String]
      #
      # @api private
      HREF_ATTRIBUTE = "href"
      private_constant :HREF_ATTRIBUTE

      # The indented HTML elements
      #
      # @return [Array<Symbol>]
      #
      # @api private
      INDENTED_HTML_ELEMENTS = %i[blockquote li].freeze
      private_constant :INDENTED_HTML_ELEMENTS

      # The mailto scheme pattern
      #
      # @return [Regexp]
      #
      # @api private
      MAILTO_SCHEME_PATTERN = /^mailto:/.freeze
      private_constant :MAILTO_SCHEME_PATTERN

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

      # The src attribute name
      #
      # @return [String]
      #
      # @api private
      SRC_ATTRIBUTE = "src"
      private_constant :SRC_ATTRIBUTE

      # The title attribute name
      #
      # @return [String]
      #
      # @api private
      TITLE_ATTRIBUTE = "title"
      private_constant :TITLE_ATTRIBUTE

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
        @highlighter = build_highlighter(@pastel, options)
        @current_indent = 0
        @footnote_number = 1
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

      # Build a {TTY::Markdown::Highlighter} instance
      #
      # @param [Pastel] pastel
      #   the pastel
      # @param [Hash] options
      #   the root element options
      #
      # @return [TTY::Markdown::Highlighter]
      #
      # @api private
      def build_highlighter(pastel, options)
        Highlighter.new(
          pastel,
          mode: options[:mode],
          styles: options[:theme][:code]
        )
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
        styles = @theme[level == 1 ? :heading1 : :header]
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

      # Convert a deleted element
      #
      # @param [Kramdown::Element] element
      #   the html element
      # @param [Hash] options
      #   the html element options
      #
      # @return [Array<String>]
      #
      # @api private
      def convert_del(element, options)
        content = transform_children(element, options).join
        decorate_each_line(content, @theme[:delete])
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
      alias convert_b convert_strong

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
      alias convert_i convert_em

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
        code = Strings.wrap(element.value, available_width)
        language = element.options[:lang]
        highlighted = @highlighter.highlight(code, language)
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
        "#{indentation}#{convert_codespan(element, options)}#{NEWLINE}"
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
        column_alignments = element.options[:alignment]
        table_data = extract_table_data(element, options)
        table_options = build_table_options(table_data, column_alignments)
        transform_children(element, options.merge(table_options)).join
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

      # Build a table element options
      #
      # @param [Array<Array<String>>] table_data
      #   the table data
      # @param [Array<Symbol>] column_alignments
      #   the table column alignments
      #
      # @return [Hash]
      #
      # @api private
      def build_table_options(table_data, column_alignments)
        max_column_widths = calculate_max_column_widths(table_data)
        column_widths = distribute_column_widths(max_column_widths)
        row_heights = calculate_max_row_heights(table_data, column_widths)
        {
          column_alignments: column_alignments,
          column_widths: column_widths,
          row_heights: row_heights,
          table_data: table_data
        }
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

        reduce_column_widths(column_widths, total_width, screen_width)
      end

      # Reduce column widths to the screen width
      #
      # @param [Array<Integer>] column_widths
      #   the table column widths
      # @param [Integer] total_width
      #   the total width of the table columns
      # @param [Integer] screen_width
      #   the screen width
      #
      # @return [Array<Integer>]
      #
      # @api private
      def reduce_column_widths(column_widths, total_width, screen_width)
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
        top_border = build_border(:top, options[:column_widths])
        content = transform_children(element, options)
        "#{indentation}#{top_border}#{NEWLINE}#{content.join}"
      end

      # Build a horizontal border line
      #
      # @param [Symbol] location
      #   the location out of :bottom, :mid or :top
      # @param [Array<Integer>] column_widths
      #   the table column widths
      #
      # @return [String]
      #
      # @api private
      def build_border(location, column_widths)
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
        top_border = build_border(top_border_type, column_widths)
        bottom_border_type = next_type == :tfoot ? :mid : :bottom
        bottom_border = build_border(bottom_border_type, column_widths)
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
        bottom_border = build_border(:bottom, options[:column_widths])
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
        add_border = options[:prev] && options[:prev].type == :tr
        border = add_border ? build_row_border(options[:column_widths]) : EMPTY
        content = transform_children(element, options)
        move_to_next_row
        "#{border}#{format_table_row(content)}"
      end

      # Build a table row border
      #
      # @param [Array<Integer>] column_widths
      #   the table column widths
      #
      # @return [String]
      #
      # @api private
      def build_row_border(column_widths)
        "#{indentation}#{build_border(:mid, column_widths)}#{NEWLINE}"
      end

      # Move to the next table row
      #
      # @return [void]
      #
      # @api private
      def move_to_next_row
        @row += 1
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
        add_indentation = @column.zero?
        cell_content = transform_children(element, options).join
        formatted_cell = format_table_cell(cell_content, options)
        number_of_columns = options[:column_widths].size
        cycle_to_next_column(number_of_columns)
        decorate_table_cell(formatted_cell, add_indentation)
      end

      # Cycle to the next table column
      #
      # @param [Integer] number_of_columns
      #   the number of table columns
      #
      # @return [void]
      #
      # @api private
      def cycle_to_next_column(number_of_columns)
        @column = (@column + 1) % number_of_columns
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
        alignment = options[:column_alignments][@column]
        align_options = alignment == :default ? {} : {direction: alignment}
        cell_height = options[:row_heights][@row]
        cell_width = options[:column_widths][@column]
        wrapped = Strings.wrap(content, cell_width)
        aligned = Strings.align(wrapped, cell_width, **align_options)
        return aligned if aligned.lines.size == cell_height

        Strings.pad(aligned, [0, 0, cell_height - aligned.lines.size, 0])
      end

      # Decorate a table cell
      #
      # @param [String] content
      #   the content to decorate
      # @param [Boolean] add_indentation
      #   whether to add indentation
      #
      # @return [Array<String>]
      #
      # @api private
      def decorate_table_cell(content, add_indentation)
        pipe = @pastel.decorate(@symbols[:pipe], *@theme[:table])
        prefix = add_indentation ? "#{indentation}#{pipe} " : EMPTY
        suffix = " #{pipe} "
        content.lines.map do |line|
          suffix_insert_index = line.end_with?(NEWLINE) ? -2 : -1
          "#{prefix}#{line.insert(suffix_insert_index, suffix)}"
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
        inner_line_width = @width - (@symbols[:diamond].length * 2)
        inner_line = @symbols[:line] * inner_line_width
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
        content = transform_children(element, options).join
        return [] if content.strip.empty?

        href = strip_mailto_scheme(element.attr[HREF_ATTRIBUTE])
        title = element.attr[TITLE_ATTRIBUTE].to_s
        build_link(content, href, title)
      end

      # Strip the mailto scheme from the href attribute
      #
      # @param [String] href
      #   the href attribute
      #
      # @return [String]
      #
      # @api private
      def strip_mailto_scheme(href)
        href.sub(MAILTO_SCHEME_PATTERN, EMPTY)
      end

      # Build a link
      #
      # @param [String] content
      #   the link content
      # @param [String] href
      #   the link href attribute
      # @param [String] title
      #   the link title attribute
      #
      # @return [Array<String>]
      #
      # @api private
      def build_link(content, href, title)
        link = []
        link << "#{content} #{@symbols[:arrow]} " if content != href
        link << "(#{title}) " unless title.strip.empty?
        link << @pastel.decorate(href, *@theme[:link])
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
          convert_codeblock(element, options)
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
        content = element.value
        footnote = fetch_or_add_footnote(name, content)
        number = footnote.last
        @pastel.decorate(@symbols.wrap_in_brackets(number), *@theme[:note])
      end

      # Fetch or add a footnote
      #
      # @param [String] name
      #   the footnote name
      # @param [String] content
      #   the footnote content
      #
      # @return [Array<Integer, String>]
      #
      # @api private
      def fetch_or_add_footnote(name, content)
        @footnotes.fetch(name) do
          add_footnote(name, content).tap do
            increment_footnote_number
          end
        end
      end

      # Add a footnote
      #
      # @param [String] name
      #   the footnote name
      # @param [String] content
      #   the footnote content
      #
      # @return [Array<Integer, String>]
      #
      # @api private
      def add_footnote(name, content)
        @footnotes[name] = [content, @footnote_number]
      end

      # Increment a footnote number
      #
      # @return [Integer]
      #
      # @api private
      def increment_footnote_number
        @footnote_number += 1
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
        alt = element.attr[ALT_ATTRIBUTE].to_s
        src = element.attr[SRC_ATTRIBUTE].to_s
        image = build_image(alt, src)
        @pastel.decorate(@symbols.wrap_in_parentheses(image), *@theme[:image])
      end

      # Build an image
      #
      # @param [String] alt
      #   the image alt attribute
      # @param [String] src
      #   the image src attribute
      #
      # @return [String]
      #
      # @api private
      def build_image(alt, src)
        return src if alt.empty?

        "#{alt} #{@symbols[:ndash]} #{src}"
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
        if CONVERTED_HTML_ELEMENTS.include?(element.value)
          send(:"convert_#{element.value}", element, options)
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
        content = strip_comment_delimiters(element.value)
        comment = build_comment(content, inline_level)
        inline_level ? comment : "#{comment}#{NEWLINE}"
      end
      alias convert_comment convert_xml_comment

      # Strip the delimiters from the HTML comment
      #
      # @param [String] comment
      #   the HTML comment
      #
      # @return [String]
      #
      # @api private
      def strip_comment_delimiters(comment)
        comment.gsub(COMMENT_DELIMITERS_PATTERN, EMPTY)
      end

      # Build a comment
      #
      # @param [String] content
      #   the comment content
      # @param [Boolean] inline_level
      #   whether the comment level is inline
      #
      # @return [String]
      #
      # @api private
      def build_comment(content, inline_level)
        content.lines.map.with_index do |line, line_index|
          (line_index.zero? && inline_level ? EMPTY : indentation) +
            @pastel.decorate("#{@symbols[:hash]} #{line.chomp}",
                             *@theme[:comment])
        end.join(NEWLINE)
      end
    end # Converter
  end # Markdown
end # TTY
