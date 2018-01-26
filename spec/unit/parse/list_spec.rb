# frozen_string_literal: true

RSpec.describe TTY::Markdown do
  let(:symbols) { TTY::Markdown.symbols }
  let(:pastel) { Pastel.new}

  it "converts unordered bulleted lists of nested items" do
    markdown =<<-TEXT
- Item 1
  - Item 2
  - Item 3
    - Item 4
    - Item 5
- Item 6
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "#{pastel.yellow(symbols[:bullet])} Item 1",
      "  #{pastel.yellow(symbols[:bullet])} Item 2",
      "  #{pastel.yellow(symbols[:bullet])} Item 3",
      "    #{pastel.yellow(symbols[:bullet])} Item 4",
      "    #{pastel.yellow(symbols[:bullet])} Item 5",
      "#{pastel.yellow(symbols[:bullet])} Item 6\n"
    ].join("\n"))
  end

  it "convert ordered numbered list of nested items" do
    markdown =<<-TEXT
1. Item 1
    2. Item 2
    3. Item 3
        4. Item 4
        5. Item 5
6. Item 6
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "#{pastel.yellow('1.')} Item 1",
      "  #{pastel.yellow('1.')} Item 2",
      "  #{pastel.yellow('2.')} Item 3",
      "    #{pastel.yellow('1.')} Item 4",
      "    #{pastel.yellow('2.')} Item 5",
      "#{pastel.yellow('2.')} Item 6\n"
    ].join("\n"))
  end

  it "converts unordered bulleted lists containing typographic symbols" do
    markdown =<<-TEXT
- ...
- --
- <<
- << Item 1
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "#{pastel.yellow(symbols[:bullet])} ...",
      "#{pastel.yellow(symbols[:bullet])} --",
      "#{pastel.yellow(symbols[:bullet])} <<",
      "#{pastel.yellow(symbols[:bullet])} << Item 1\n"
    ].join("\n"))
  end
end
