require_relative '../lib/tty-markdown'

path = File.join(__dir__, 'man.md')
out = TTY::Markdown.parse_file(path, colors: 256)

puts out
