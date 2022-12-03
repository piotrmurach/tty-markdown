# frozen_string_literal: true

require "kramdown/document"
require "tty-color"
require "tty-screen"

require_relative "markdown/converter"
require_relative "markdown/version"
require_relative "markdown/kramdown_ext"

module TTY
  # Responsible for converting Markdown to the terminal output
  #
  # @api public
  module Markdown
    SYMBOLS = {
      arrow: "»",
      bullet: "●",
      bar: "┃",
      diamond: "◈",
      pipe: "│",
      line: "─",
      hellip: "…",
      laquo: "«",
      laquo_space: "« ",
      raquo: "»",
      raquo_space: " »",
      ndash: "-",
      mdash: "\u2014",
      lsquo: "‘",
      rsquo: "’",
      ldquo: "“",
      rdquo: "”",
      top_left: "┌",
      top_right: "┐",
      top_center: "┬",
      mid_left: "├",
      mid_right: "┤",
      mid_center: "┼",
      bottom_right: "┘",
      bottom_left: "└",
      bottom_center: "┴",
      paren_left: "(",
      paren_right: ")",
      bracket_left: "[",
      bracket_right: "]",
      hash: "#",
      delete: "\u0336"
    }.freeze

    ASCII_SYMBOLS = {
      arrow: "->",
      bullet: "*",
      diamond: "*",
      bar: "│",
      pipe: "|",
      line: "-",
      hellip: "...",
      laquo: "<<",
      laquo_space: "<< ",
      raquo: ">>",
      raquo_space: " >>",
      ndash: "-",
      mdash: "--",
      lsquo: "\"",
      rsquo: "\"",
      ldquo: "\"",
      rdquo: "\"",
      top_left: "+",
      top_right: "+",
      top_center: "+",
      mid_left: "+",
      mid_right: "+",
      mid_center: "+",
      bottom_right: "+",
      bottom_left: "+",
      bottom_center: "+",
      paren_left: "(",
      paren_right: ")",
      bracket_left: "[",
      bracket_right: "]",
      hash: "#",
      delete: "\u0336"
    }.freeze

    THEME = {
      em: :yellow,
      header: %i[cyan bold],
      hr: :yellow,
      link: %i[yellow underline],
      list: :yellow,
      strong: %i[yellow bold],
      table: :yellow,
      quote: :yellow,
      image: :bright_black,
      note: :yellow,
      comment: :bright_black
    }.freeze

    # Parse a markdown string
    #
    # @example
    #   TTY::Markdown.parse("# Header")
    #
    # @param [String] source
    #   the source with markdown
    # @param [String, Symbol] color
    #   the output coloring support out of always, auto or never
    # @param [Integer] indent
    #   the converted output indent
    # @param [Integer] mode
    #   the number of supported colors
    # @param [Hash, String, Symbol, nil] symbols
    #   the converted output symbols
    # @param [Hash{Symbol => Array, String, Symbol}, nil] theme
    #   the converted output color theme
    # @param [Integer] width
    #   the width at which to wrap content
    # @param [Hash] doc_opts
    #   the markdown document parser options
    #
    # @return [String]
    #   the converted terminal output
    #
    # @api public
    def parse(source,
              color: :auto,
              indent: 2,
              mode: TTY::Color.mode,
              symbols: {},
              theme: {},
              width: TTY::Screen.width,
              **doc_opts)
      converter_options = {
        enabled: color_enabled(color),
        indent: indent,
        input: "KramdownExt",
        mode: mode,
        symbols: build_symbols(symbols),
        theme: build_theme(theme),
        width: width
      }
      doc = Kramdown::Document.new(source, converter_options.merge(doc_opts))
      Converter.convert(doc.root, doc.options).join
    end
    module_function :parse

    # Parse a markdown document
    #
    # @example
    #   TTY::Markdown.parse_file("example.md")
    #
    # @param [String] path
    #   the file path
    # @param [Hash] options
    #   the conversion options
    #
    # @return [String]
    #   the converted terminal output
    #
    # @api public
    def parse_file(path, **options)
      parse(::File.read(path), **options)
    end
    module_function :parse_file

    # Convert color option to Pastel option
    #
    # @param [String, Symbol] color
    #   the color option to convert
    #
    # @return [Boolean, nil]
    #
    # @api private
    def color_enabled(color)
      case color.to_s
      when "always" then true
      when "never"  then false
      end
    end
    module_function :color_enabled
    private_class_method :color_enabled

    # Build symbols hash from the provided symbols option
    #
    # @param [Hash, String, Symbol, nil] symbols
    #   the converted output symbols
    #
    # @return [Hash{Symbol => String}]
    #
    # @api private
    def build_symbols(symbols)
      case symbols
      when String, Symbol
        select_symbols(symbols)
      when Hash
        base_symbols = select_symbols(symbols[:base])
        base_symbols.merge(symbols[:override].to_h)
      else
        SYMBOLS
      end
    end
    module_function :build_symbols
    private_class_method :build_symbols

    # Select between ASCII or Unicode symbols
    #
    # @param [String, Symbol, nil] name
    #   the symbols name
    #
    # @return [Hash{Symbol => String}]
    #
    # @api private
    def select_symbols(name)
      name.to_s == "ascii" ? ASCII_SYMBOLS : SYMBOLS
    end
    module_function :select_symbols
    private_class_method :select_symbols

    # Build theme hash from the provided theme option
    #
    # @param [Hash{Symbol => Array, String, Symbol}, nil] theme
    #   the converted output theme
    #
    # @return [Hash{Symbol => Array<Symbol>}]
    #
    # @api private
    def build_theme(theme)
      THEME.merge(theme.to_h) do |*, new_style|
        Array(new_style).map(&:to_sym)
      end
    end
    module_function :build_theme
    private_class_method :build_theme
  end # Markdown
end # TTY
