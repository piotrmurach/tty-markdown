# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'blockquote' do
  let(:bar) { TTY::Markdown.symbols[:bar] }
  let(:apos) { TTY::Markdown.symbols[:rsquo] }

  it "converts single blockquote" do
    markdown =<<-TEXT
> Oh, you can *put* **Markdown** into a blockquote.
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "\e[33m#{bar}\e[0m  Oh, you can \e[33mput\e[0m \e[33;1mMarkdown\e[0m into a blockquote.\n"
    ].join)
  end

  it "indents blockquote within header" do
    markdown =<<-TEXT
### Quote
> Oh, you can *put* **Markdown** into a blockquote.
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "    \e[36;1mQuote\e[0m",
      "    \e[33m#{bar}\e[0m  Oh, you can \e[33mput\e[0m \e[33;1mMarkdown\e[0m into a blockquote.\n"
    ].join("\n"))
  end

  it "converts multiple blockquotes without header" do
    markdown =<<-TEXT
> one
> two
> three
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expected_output =
      "\e[33m#{bar}\e[0m  one\n" +
      "\e[33m#{bar}\e[0m  two\n" +
      "\e[33m#{bar}\e[0m  three\n"

    expect(parsed).to eq(expected_output)
  end

  it "converts multiple blockquote" do
    markdown =<<-TEXT
### Quote
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.
> *Oh*, you can put **Markdown** into a blockquote.
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "    \e[36;1mQuote\e[0m\n",
      "    \e[33m#{bar}\e[0m  Blockquotes are very handy in email to emulate reply text.\n",
      "    \e[33m#{bar}\e[0m  This line is part of the same quote.\n",
      "    \e[33m#{bar}\e[0m  \e[33mOh\e[0m, you can put \e[33;1mMarkdown\e[0m into a blockquote.\n"
    ].join)
  end

  it "converts blockquote into lines" do
    markdown =<<-TEXT
> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote.
> Last line to ensure all is fine.
    TEXT

    parsed = TTY::Markdown.parse(markdown, width: 50)
    expected_output =
      "\e[33m#{bar}\e[0m  This is a very long line that will still be \n" +
      "\e[33m#{bar}\e[0m  quoted properly when it wraps. Oh boy let\n" +
      "\e[33m#{bar}\e[0m  #{apos}s keep writing to make sure this is long enough \n" +
      "\e[33m#{bar}\e[0m  to actually wrap for everyone. Oh, you can \n" +
      "\e[33m#{bar}\e[0m  \e[33mput\e[0m \e[33;1mMarkdown\e[0m into a blockquote.\n" +
      "\e[33m#{bar}\e[0m  Last line to ensure all is fine.\n"

    expect(parsed).to eq(expected_output)
  end
end
