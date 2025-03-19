# frozen_string_literal: true

RSpec.describe TTY::Markdown, "blockquote" do
  let(:bar) { TTY::Markdown::SYMBOLS[:bar] }
  let(:apos) { TTY::Markdown::SYMBOLS[:rsquo] }

  it "converts single blockquote" do
    markdown =<<-TEXT
> Oh, you can *put* **Markdown** into a blockquote.
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, symbols: :unicode)
    expect(parsed).to eq([
      "\e[33m#{bar}\e[0m  Oh, you can \e[33mput\e[0m \e[33;1mMarkdown\e[0m into a blockquote.\n"
    ].join)
  end

  it "indents blockquote within header" do
    markdown =<<-TEXT
### Quote
> Oh, you can *put* **Markdown** into a blockquote.
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, symbols: :unicode)
    expected_output = [
      "    \e[36;1mQuote\e[0m",
      "    \e[33m#{bar}\e[0m  Oh, you can \e[33mput\e[0m \e[33;1mMarkdown\e[0m into a blockquote.\n"
    ].join("\n")

    expect(parsed).to eq(expected_output)
  end

  it "converts multiple blockquotes without header" do
    markdown =<<-TEXT
> one
> two
> three
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, symbols: :unicode)
    expected_output =
      "\e[33m#{bar}\e[0m  one\n" +
      "\e[33m#{bar}\e[0m  two\n" +
      "\e[33m#{bar}\e[0m  three\n"

    expect(parsed).to eq(expected_output)
  end

  it "converts quote with an apostrophe" do
    markdown =<<-TEXT
> I try it this way.\nBut it#{apos}s not good.
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, symbols: :unicode)
    expect(parsed).to eq([
      "\e[33m#{bar}\e[0m  I try it this way.",
      "\e[33m#{bar}\e[0m  But it#{apos}s not good.\n"
    ].join("\n"))
  end

  it "converts quote with multiline strong style" do
    markdown =<<-TEXT
> **Human madness is oftentimes a cunning and most feline thing. When you think it fled, it may have but become transfigured into some still subtler form.**
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, symbols: :unicode,
                                           width: 50)
    expect(parsed).to eq([
      "\e[33m#{bar}\e[0m  \e[33;1mHuman madness is oftentimes a cunning and most \e[0m",
      "\e[33m#{bar}\e[0m  \e[33;1mfeline thing. When you think it fled, it may have \e[0m",
      "\e[33m#{bar}\e[0m  \e[33;1mbut become transfigured into some still subtler \e[0m",
      "\e[33m#{bar}\e[0m  \e[33;1mform.\e[0m\n",
    ].join("\n"))
  end

  it "converts multiple blockquote" do
    markdown =<<-TEXT
### Quote
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.
> *Oh*, you can put **Markdown** into a blockquote.
    TEXT
    parsed = TTY::Markdown.parse(markdown, color: :always, symbols: :unicode)
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

    parsed = TTY::Markdown.parse(markdown, color: :always, symbols: :unicode,
                                           width: 50)
    expected_output =
      "\e[33m#{bar}\e[0m  This is a very long line that will still be \n" +
      "\e[33m#{bar}\e[0m  quoted properly when it wraps. Oh boy let#{apos}s keep writing to make sure this is long enough \n" +
      "\e[33m#{bar}\e[0m  to actually wrap for everyone. Oh, you can \e[33mput\e[0m \e[33;1mMarkdown\e[0m into a blockquote.\n" +
      "\e[33m#{bar}\e[0m  Last line to ensure all is fine.\n"

    expect(parsed).to eq(expected_output)
  end
end
