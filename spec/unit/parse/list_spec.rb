# frozen_string_literal: true

RSpec.describe TTY::Markdown do
  let(:symbols) { TTY::Markdown.symbols }

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
      "#{symbols[:bullet]} Item 1",
      "",
      "  #{symbols[:bullet]} Item 2",
      "  #{symbols[:bullet]} Item 3",
      "",
      "    #{symbols[:bullet]} Item 4",
      "    #{symbols[:bullet]} Item 5",
      "#{symbols[:bullet]} Item 6\n"
    ].join("\n"))
  end

  it "convert ordered numbered list of nested items" do
    markdown =<<-TEXT
1. Item 1
  2. Item 2
  3. Item 3
    1. Item 4
    2. Item 5
6. Item 6
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq([
      "1. Item 1",
      "2. Item 2",
      "3. Item 3",
      "    1. Item 4",
      "    2. Item 5",
      "4. Item 6\n"
    ].join("\n"))
  end
end
