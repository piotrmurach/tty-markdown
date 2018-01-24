# frozen_string_literal: true

RSpec.describe TTY::Markdown do
  let(:bar) { TTY::Markdown.symbols[:bar] }

  it "converts single blockquote" do
    markdown =<<-TEXT
> Oh, you can *put* **Markdown** into a blockquote.
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "\e[33m#{bar}\e[0m Oh, you can \e[3mput\e[0m \e[33;1mMarkdown\e[0m into a blockquote.\n"
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
      "    \e[33m#{bar}\e[0m Oh, you can \e[3mput\e[0m \e[33;1mMarkdown\e[0m into a blockquote.\n"
    ].join("\n"))
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
      "    \e[33m#{bar}\e[0m Blockquotes are very handy in email to emulate reply text.\n",
      "    \e[33m#{bar}\e[0m This line is part of the same quote.\n",
      "    \e[33m#{bar}\e[0m \e[3mOh\e[0m, you can put \e[33;1mMarkdown\e[0m into a blockquote.\n"
    ].join)
  end

  it "converts blockquote into lines" do
    pending "impelement terminal wrapping for long quotes"
    markdown =<<-TEXT
> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote.
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
    ].join)
  end
end
