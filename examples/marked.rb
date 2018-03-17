require_relative '../lib/tty-markdown'

path = File.join(__dir__, 'example.md')
out = TTY::Markdown.parse_file(path, colors: 256, width: 80)

puts out
