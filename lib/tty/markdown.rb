# frozen_string_literal: true

require 'kramdown'
require "tty-color"
require "tty-screen"

require_relative 'markdown/parser'
require_relative 'markdown/version'

module TTY
  module Markdown
    SYMBOLS = {
      arrow: '»',
      bullet: '●',
      bar: '┃',
      diamond: '◈',
      pipe: '│',
      line: '─',
      hellip: '…',
      laquo: '«',
      laquo_space: '« ',
      raquo: '»',
      raquo_space: ' »',
      ndash: '-',
      mdash: "\u2014",
      lsquo: '‘',
      rsquo: '’',
      ldquo: '“',
      rdquo: '”',
      top_left: '┌',
      top_right: '┐',
      top_center: '┬',
      mid_left: '├',
      mid_right: '┤',
      mid_center: '┼',
      bottom_right: '┘',
      bottom_left: '└',
      bottom_center: '┴',
    }.freeze

    ASCII_SYMBOLS = {
      arrow: '->',
      bullet: '*',
      diamond: '*',
      bar: '│',
      pipe: '|',
      line: '─',
      hellip: '...',
      laquo: '<<',
      laquo_space: '<< ',
      raquo: '>>',
      raquo_space: ' >>',
      ndash: '-',
      mdash: "--",
      lsquo: '\'',
      rsquo: '\'',
      ldquo: '"',
      rdquo: '"',
      top_left: '+',
      top_right: '+',
      top_center: '+',
      mid_left: '+',
      mid_right: '+',
      mid_center: '+',
      bottom_right: '+',
      bottom_left: '+',
      bottom_center: '+'
    }.freeze

    THEME = {
      em: :yellow,
      header: [:cyan, :bold],
      hr: :yellow,
      link: [:yellow, :underline],
      list: :yellow,
      strong: [:yellow, :bold],
      table: :yellow,
      quote: :yellow,
    }.freeze

    # Parse a markdown string
    #
    # @param [String] source
    #   the source with markdown
    # @param [Integer] :colors
    #   a number of colors supported
    # @param [Integer] :indent
    #   the indent of the converted output
    # @param [Hash<Symbol, String>] :symbols
    #   the symbols to use when generating output
    # @param [Hash<Symbol, Symbol>] :theme
    #   the color names for markdown elements
    # @param [Integer] :width
    #   the width at which to wrap content
    # @param [Hash] :doc_opts
    #   the markdown document parser options
    #
    # @api public
    def parse(source, width: TTY::Screen.width, theme: THEME, indent: 2,
                      colors: TTY::Color.mode, symbols: {}, **doc_opts)
      convert_options = { width: width, indent: indent, theme: theme,
                          colors: colors, symbols: symbols }
      doc = Kramdown::Document.new(source, convert_options.merge(doc_opts))
      Parser.convert(doc.root, doc.options).join
    end
    module_function :parse

    # Pase a markdown document
    #
    # @api public
    def parse_file(path, **options)
      parse(::File.read(path), **options)
    end
    module_function :parse_file
  end # Markdown
end # TTY
