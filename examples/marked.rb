require_relative '../lib/tty-markdown'

path = File.join(__dir__, 'example.md')
out = TTY::Markdown.parse(File.read(path), colors: 256)

puts out
