# frozen_string_literal: true

require 'kramdown'

require_relative 'markdown/parser'
require_relative 'markdown/version'

module TTY
  module Markdown
    SYMBOLS = {
      bullet: '●'
    }

    WIN_SYMBOLS = {
      bullet: '*'
    }

    # Parse markdown text
    #
    # @param [String] source
    #   the source with markdown
    #
    # @api public
    def parse(source, **options)
      doc = Kramdown::Document.new(source, options)
      Parser.convert(doc.root, doc.options).join
    end
    module_function :parse

    def symbols
      @symbols ||= windows? ? WIN_SYMBOLS : SYMBOLS
    end
    module_function :symbols

    def windows?
      ::File::ALT_SEPARATOR == "\\"
    end
    module_function :windows?
  end # Markdown
end # TTY
