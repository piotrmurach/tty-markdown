# frozen_string_literal: true

RSpec.describe TTY::Markdown do
  let(:symbols) { TTY::Markdown.symbols }

  it "converts header with typographic symbols" do
    markdown =<<-TEXT
--- << typographic >> ... symbols --
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("#{symbols[:mdash]} #{symbols[:laquo]} typographic #{symbols[:raquo]} #{symbols[:hellip]} symbols #{symbols[:ndash]}\n")
  end
end
