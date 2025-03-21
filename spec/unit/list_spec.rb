# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  let(:pastel) { Pastel.new(enabled: true) }

  it "converts unordered bulleted lists of nested items" do
    markdown = <<-TEXT
- Item 1
  - Item 2
  - Item 3
    - Item 4
    - Item 5
- Item 6
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "#{pastel.yellow("●")} Item 1",
      "  #{pastel.yellow("●")} Item 2",
      "  #{pastel.yellow("●")} Item 3",
      "    #{pastel.yellow("●")} Item 4",
      "    #{pastel.yellow("●")} Item 5",
      "#{pastel.yellow("●")} Item 6\n"
    ].join("\n"))
  end

  it "indents unordered list" do
    markdown = <<-TEXT
### header
- Item 1
  - Item 2
  - Item 3
    - Item 4
    - Item 5
- Item 6
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m",
      "    #{pastel.yellow("●")} Item 1",
      "      #{pastel.yellow("●")} Item 2",
      "      #{pastel.yellow("●")} Item 3",
      "        #{pastel.yellow("●")} Item 4",
      "        #{pastel.yellow("●")} Item 5",
      "    #{pastel.yellow("●")} Item 6\n"
    ].join("\n"))
  end

  it "indents unordered list with multiline content" do
    markdown = <<-TEXT
### header
- First multiline
  Item 1
  - Second multiline
    Item 2
  - Item 3
- Item 4
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "    \e[36;1mheader\e[0m",
      "    #{pastel.yellow("●")} First multiline",
      "    Item 1",
      "      #{pastel.yellow("●")} Second multiline",
      "      Item 2",
      "      #{pastel.yellow("●")} Item 3",
      "    #{pastel.yellow("●")} Item 4\n"
    ].join("\n"))
  end

  it "displays inline codeblocks in lists correctly" do
    markdown = <<-TEXT
- Version: run `ruby -v` or `ruby --version`.
- Help: run `ruby -h` or `ruby --help`.
    TEXT

    parsed = described_class.parse(
      markdown, color: :always, mode: 16, symbols: :unicode
    )

    expect(parsed).to eq([
      "#{pastel.yellow("●")} Version: run \e[33mruby -v\e[0m ",
      "or \e[33mruby --version\e[0m.\n",
      "#{pastel.yellow("●")} Help: run \e[33mruby -h\e[0m ",
      "or \e[33mruby --help\e[0m.\n"
    ].join)
  end

  it "convert ordered numbered list of nested items" do
    markdown = <<-TEXT
1. Item 1
    2. Item 2
    3. Item 3
        4. Item 4
        5. Item 5
6. Item 6
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "#{pastel.yellow("1.")} Item 1",
      "  #{pastel.yellow("1.")} Item 2",
      "  #{pastel.yellow("2.")} Item 3",
      "    #{pastel.yellow("1.")} Item 4",
      "    #{pastel.yellow("2.")} Item 5",
      "#{pastel.yellow("2.")} Item 6\n"
    ].join("\n"))
  end
end
