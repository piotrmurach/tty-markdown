# frozen_string_literal: true

require "kramdown/document"
require "tty-color"
require "tty-screen"

require_relative "markdown/color"
require_relative "markdown/converter"
require_relative "markdown/parser"
require_relative "markdown/symbols"
require_relative "markdown/theme"
require_relative "markdown/version"

module TTY
  # Responsible for converting Markdown to the terminal output
  #
  # @api public
  class Markdown
    # The input parser name
    #
    # @return [String]
    #
    # @api private
    INPUT_PARSER = "TTYMarkdown"
    private_constant :INPUT_PARSER

    # Parse Markdown content
    #
    # @example
    #   TTY::Markdown.parse("# TTY Toolkit")
    #
    # @example
    #   TTY::Markdown.parse("# TTY Toolkit", mode: 16)
    #
    # @param [String] content
    #   the Markdown content
    # @param [Hash] options
    #   the conversion options
    #
    # @return [String]
    #   the converted terminal output
    #
    # @raise [TTY::Markdown::Error]
    #   when the option value is invalid
    #
    # @see #initialize
    #
    # @api public
    def self.parse(content, **options)
      new(**options).parse(content)
    end

    # Parse a Markdown file
    #
    # @example
    #   TTY::Markdown.parse_file("example.md")
    #
    # @example
    #   TTY::Markdown.parse_file("example.md", mode: 16)
    #
    # @param [String] path
    #   the Markdown file path
    # @param [Hash] options
    #   the conversion options
    #
    # @return [String]
    #   the converted terminal output
    #
    # @raise [TTY::Markdown::Error]
    #   when the option value is invalid
    #
    # @see #initialize
    #
    # @api public
    def self.parse_file(path, **options)
      new(**options).parse_file(path)
    end

    # Create a {TTY::Markdown} instance
    #
    # @example
    #   tty_markdown = TTY::Markdown.new
    #
    # @example
    #   tty_markdown = TTY::Markdown.new(mode: 16)
    #
    # @example
    #   tty_markdown = TTY::Markdown.new(symbols: :ascii)
    #
    # @example
    #   tty_markdown = TTY::Markdown.new(theme: {link: :blue})
    #
    # @param [String, Symbol] color
    #   the color support out of always, auto or never
    # @param [Integer] indent
    #   the output indent
    # @param [Integer] mode
    #   the color mode
    # @param [Hash, String, Symbol, nil] symbols
    #   the output symbols
    # @param [Hash{Symbol => Array, String, Symbol}, nil] theme
    #   the color theme
    # @param [Integer] width
    #   the maximum width
    # @param [Hash] document_options
    #   the document parser options
    #
    # @raise [TTY::Markdown::Error]
    #   when the option value is invalid
    #
    # @api public
    def initialize(
      color: :auto,
      indent: 2,
      mode: TTY::Color.mode,
      symbols: {},
      theme: {},
      width: TTY::Screen.width,
      **document_options
    )
      @converter_options = {
        enabled: Color.new(color).to_enabled,
        indent: indent,
        input: INPUT_PARSER,
        mode: mode,
        symbols: Symbols.from(symbols),
        theme: Theme.from(theme),
        width: width
      }.merge(document_options)
    end

    # Parse Markdown content
    #
    # @example
    #   tty_markdown.parse("# TTY Toolkit")
    #
    # @param [String] content
    #   the Markdown content
    #
    # @return [String]
    #   the converted terminal output
    #
    # @api public
    def parse(content)
      document = Kramdown::Document.new(content, @converter_options)
      Converter.convert(document.root, document.options).join
    end

    # Parse a Markdown file
    #
    # @example
    #   tty_markdown.parse_file("example.md")
    #
    # @param [String] path
    #   the Markdown file path
    #
    # @return [String]
    #   the converted terminal output
    #
    # @api public
    def parse_file(path)
      parse(::File.read(path))
    end
  end # Markdown
end # TTY
