# frozen_string_literal: true

RSpec.describe TTY::Markdown do
  it "parses markdown table" do
    pending "implement table rendering"
    markdown =<<-TEXT
| Tables   |      Are      |  Cool |
|----------|:-------------:|------:|
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is | right-aligned |    $1 |
    TEXT

    parsed = TTY::Markdown.parse(markdown)

    expect(parsed).to eq([
    ].join)
  end
end
