# frozen_string_literal: true

RSpec.describe TTY::Markdown do
  it "converts blockquote " do
    markdown =<<-TEXT
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "| Blockquotes are very handy in email to emulate reply text.\n",
      "| This line is part of the same quote.\n"
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
