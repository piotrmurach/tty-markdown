# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "parses markdown table with header" do
    markdown = <<-TEXT
| Tables   |      Are      |  Cool |
|----------|:-------------:|------:|
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is | right-aligned |    $1 |
|==========|===============|=======|
| Footers  |  are cool     | too   |
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "\e[33m┌#{"─" * 10}┬#{"─" * 15}┬#{"─" * 7}┐\e[0m\n",
      "\e[33m│\e[0m Tables   ",
      "\e[33m│\e[0m      Are      ",
      "\e[33m│\e[0m  Cool \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 10}┼#{"─" * 15}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m col 1 is ",
      "\e[33m│\e[0m left-aligned  ",
      "\e[33m│\e[0m $1600 \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 10}┼#{"─" * 15}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m col 2 is ",
      "\e[33m│\e[0m   centered    ",
      "\e[33m│\e[0m   $12 \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 10}┼#{"─" * 15}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m col 3 is ",
      "\e[33m│\e[0m right-aligned ",
      "\e[33m│\e[0m    $1 \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 10}┼#{"─" * 15}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m Footers  ",
      "\e[33m│\e[0m   are cool    ",
      "\e[33m│\e[0m   too \e[33m│\e[0m \n",
      "\e[33m└#{"─" * 10}┴#{"─" * 15}┴#{"─" * 7}┘\e[0m\n"
    ].join)
  end

  it "parses markdown table without header" do
    markdown = <<-TEXT
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is | right-aligned |    $1 |
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "\e[33m┌#{"─" * 10}┬#{"─" * 15}┬#{"─" * 7}┐\e[0m\n",
      "\e[33m│\e[0m col 1 is ",
      "\e[33m│\e[0m left-aligned  ",
      "\e[33m│\e[0m $1600 \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 10}┼#{"─" * 15}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m col 2 is ",
      "\e[33m│\e[0m centered      ",
      "\e[33m│\e[0m $12   \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 10}┼#{"─" * 15}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m col 3 is ",
      "\e[33m│\e[0m right-aligned ",
      "\e[33m│\e[0m $1    \e[33m│\e[0m \n",
      "\e[33m└#{"─" * 10}┴#{"─" * 15}┴#{"─" * 7}┘\e[0m\n"
    ].join)
  end

  it "wraps multiline records" do
    markdown = <<-TEXT
| Tables   |      Are      |  Cool |
|----------|:-------------:|------:|
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is a multiline column | right-aligned has also a very long content that wraps around |    $1 |
    TEXT
    parsed = described_class.parse(
      markdown, color: :always, symbols: :unicode, width: 80
    )

    expect(parsed).to eq([
      "\e[33m┌#{"─" * 24}┬#{"─" * 51}┬#{"─" * 7}┐\e[0m\n",
      "\e[33m│\e[0m Tables                 ",
      "\e[33m│\e[0m                        Are                        ",
      "\e[33m│\e[0m  Cool \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 24}┼#{"─" * 51}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m col 1 is               ",
      "\e[33m│\e[0m                   left-aligned                    ",
      "\e[33m│\e[0m $1600 \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 24}┼#{"─" * 51}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m col 2 is               ",
      "\e[33m│\e[0m                     centered                      ",
      "\e[33m│\e[0m   $12 \e[33m│\e[0m \n",
      "\e[33m├#{"─" * 24}┼#{"─" * 51}┼#{"─" * 7}┤\e[0m\n",
      "\e[33m│\e[0m col 3 is a multiline   ",
      "\e[33m│\e[0m right-aligned has also a very long content that   ",
      "\e[33m│\e[0m    $1 \e[33m│\e[0m \n",
      "\e[33m│\e[0m column                 ",
      "\e[33m│\e[0m                   wraps around                    ",
      "\e[33m│\e[0m       \e[33m│\e[0m \n",
      "\e[33m└#{"─" * 24}┴#{"─" * 51}┴#{"─" * 7}┘\e[0m\n"
    ].join)
  end

  it "formats empty cells correctly" do
    markdown = <<-TEXT
| a |
|---|
|   |
|   |
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "\e[33m┌#{"─" * 3}┐\e[0m",
      "\e[33m│\e[0m a \e[33m│\e[0m ",
      "\e[33m├#{"─" * 3}┤\e[0m",
      "\e[33m│\e[0m   \e[33m│\e[0m ",
      "\e[33m├#{"─" * 3}┤\e[0m",
      "\e[33m│\e[0m   \e[33m│\e[0m ",
      "\e[33m└#{"─" * 3}┘\e[0m\n"
    ].join("\n"))
  end

  it "indents within the specified width" do
    markdown = <<-TEXT
### Header3

| foo | bar | baz |
    TEXT
    parsed = described_class.parse(
      markdown, color: :always, symbols: :unicode, width: 20
    )

    expect(parsed).to eq([
      "    \e[36;1mHeader3\e[0m\n",
      "    \e[33m┌#{"─" * 4}┬#{"─" * 4}┬#{"─" * 4}┐\e[0m",
      "    \e[33m│\e[0m fo \e[33m│\e[0m ba \e[33m│\e[0m ba \e[33m│\e[0m ",
      "    \e[33m│\e[0m o  \e[33m│\e[0m r  \e[33m│\e[0m z  \e[33m│\e[0m ",
      "    \e[33m└#{"─" * 4}┴#{"─" * 4}┴#{"─" * 4}┘\e[0m\n"
    ].join("\n"))
  end

  it "formats identical content within the specified width" do
    markdown = <<-TEXT
| foo | foo | foo |
    TEXT
    parsed = described_class.parse(
      markdown, color: :always, symbols: :unicode, width: 20
    )

    expect(parsed).to eq([
      "\e[33m┌#{"─" * 5}┬#{"─" * 5}┬#{"─" * 5}┐\e[0m",
      "\e[33m│\e[0m foo \e[33m│\e[0m foo \e[33m│\e[0m foo \e[33m│\e[0m ",
      "\e[33m└#{"─" * 5}┴#{"─" * 5}┴#{"─" * 5}┘\e[0m\n"
    ].join("\n"))
  end

  it "parses markdown table with ASCII border" do
    markdown = <<-TEXT
|foo|bar|
|---|---|
| a | b |
|===|===|
|baz|qux|
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :ascii)

    expect(parsed).to eq([
      "\e[33m+-----+-----+\e[0m\n",
      "\e[33m|\e[0m foo \e[33m|\e[0m bar \e[33m|\e[0m \n",
      "\e[33m+-----+-----+\e[0m\n",
      "\e[33m|\e[0m a   \e[33m|\e[0m b   \e[33m|\e[0m \n",
      "\e[33m+-----+-----+\e[0m\n",
      "\e[33m|\e[0m baz \e[33m|\e[0m qux \e[33m|\e[0m \n",
      "\e[33m+-----+-----+\e[0m\n"
    ].join)
  end
end
