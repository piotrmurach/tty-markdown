# frozen_string_literal: true

require_relative "../lib/tty-markdown"

markdown =<<-TEXT

## Blockquote

> Human madness is oftentimes a cunning and most feline thing. When you think it fled, it may have but become transfigured into some still subtler form.

## With inline styles

> Human madness is oftentimes a **cunning** and most feline thing. When you think it fled, it may have but become *transfigured* into some still subtler form.

## Long Quote

> *London (/ˈlʌndən/ (About this soundlisten) LUN-dən) is the capital and largest city of both England and the United Kingdom. Standing on the River Thames in the south-east of England, at the head of its 50-mile (80 km) estuary leading to the North Sea, London has been a major settlement for two millennia.*

## With apostrophe

> I know not all that may be coming,\nbut be it what it will, I'll go to it laughing.

TEXT

print TTY::Markdown.parse(markdown, width: 80)
