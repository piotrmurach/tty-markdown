# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'table' do
  let(:symbols) { TTY::Markdown.symbols }

  it "parses markdown table with header" do
    markdown =<<-TEXT
| Tables   |      Are      |  Cool |
|----------|:-------------:|------:|
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is | right-aligned |    $1 |
    TEXT

    parsed = TTY::Markdown.parse(markdown)

    expect(parsed).to eq([
      "\e[33m#{symbols[:top_left]}#{symbols[:line]*10}#{symbols[:top_center]}",
      "#{symbols[:line]*15}#{symbols[:top_center]}",
      "#{symbols[:line]*7}#{symbols[:top_right]}",
      "\e[0m\n",

      "\e[33m#{symbols[:pipe]} \e[0mTables   ",
      "\e[33m#{symbols[:pipe]}\e[0m      Are      ",
      "\e[33m#{symbols[:pipe]}\e[0m  Cool \e[33m#{symbols[:pipe]}\e[0m \n",

      "\e[33m#{symbols[:mid_left]}#{symbols[:line]*10}#{symbols[:mid_center]}",
      "#{symbols[:line]*15}#{symbols[:mid_center]}",
      "#{symbols[:line]*7}#{symbols[:mid_right]}",
      "\e[0m\n",

      "\e[33m#{symbols[:pipe]} \e[0mcol 1 is ",
      "\e[33m#{symbols[:pipe]}\e[0m left-aligned  ",
      "\e[33m#{symbols[:pipe]}\e[0m $1600 \e[33m#{symbols[:pipe]}\e[0m \n",

      "\e[33m#{symbols[:mid_left]}#{symbols[:line]*10}#{symbols[:mid_center]}",
      "#{symbols[:line]*15}#{symbols[:mid_center]}",
      "#{symbols[:line]*7}#{symbols[:mid_right]}",
      "\e[0m\n",

      "\e[33m#{symbols[:pipe]} \e[0mcol 2 is ",
      "\e[33m#{symbols[:pipe]}\e[0m   centered    ",
      "\e[33m#{symbols[:pipe]}\e[0m   $12 \e[33m#{symbols[:pipe]}\e[0m \n",

      "\e[33m#{symbols[:mid_left]}#{symbols[:line]*10}#{symbols[:mid_center]}",
      "#{symbols[:line]*15}#{symbols[:mid_center]}",
      "#{symbols[:line]*7}#{symbols[:mid_right]}",
      "\e[0m\n",

      "\e[33m#{symbols[:pipe]} \e[0mcol 3 is ",
      "\e[33m#{symbols[:pipe]}\e[0m right-aligned ",
      "\e[33m#{symbols[:pipe]}\e[0m    $1 \e[33m#{symbols[:pipe]}\e[0m \n",

      "\e[33m#{symbols[:bottom_left]}#{symbols[:line]*10}#{symbols[:bottom_center]}",
      "#{symbols[:line]*15}#{symbols[:bottom_center]}",
      "#{symbols[:line]*7}#{symbols[:bottom_right]}",
      "\e[0m\n"
    ].join)
  end

  it "parses markdown table without header" do
    markdown =<<-TEXT
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is | right-aligned |    $1 |
    TEXT

    parsed = TTY::Markdown.parse(markdown)

    expect(parsed).to eq([
      "\e[33m#{symbols[:top_left]}#{symbols[:line]*10}#{symbols[:top_center]}",
      "#{symbols[:line]*15}#{symbols[:top_center]}",
      "#{symbols[:line]*7}#{symbols[:top_right]}",
      "\e[0m\n",

      "\e[33m#{symbols[:pipe]} \e[0mcol 1 is ",
      "\e[33m#{symbols[:pipe]}\e[0m left-aligned  ",
      "\e[33m#{symbols[:pipe]}\e[0m $1600 \e[33m#{symbols[:pipe]}\e[0m \n",

      "\e[33m#{symbols[:mid_left]}#{symbols[:line]*10}#{symbols[:mid_center]}",
      "#{symbols[:line]*15}#{symbols[:mid_center]}",
      "#{symbols[:line]*7}#{symbols[:mid_right]}",
      "\e[0m\n",

      "\e[33m#{symbols[:pipe]} \e[0mcol 2 is ",
      "\e[33m#{symbols[:pipe]}\e[0m centered      ",
      "\e[33m#{symbols[:pipe]}\e[0m $12   \e[33m#{symbols[:pipe]}\e[0m \n",

      "\e[33m#{symbols[:mid_left]}#{symbols[:line]*10}#{symbols[:mid_center]}",
      "#{symbols[:line]*15}#{symbols[:mid_center]}",
      "#{symbols[:line]*7}#{symbols[:mid_right]}",
      "\e[0m\n",

      "\e[33m#{symbols[:pipe]} \e[0mcol 3 is ",
      "\e[33m#{symbols[:pipe]}\e[0m right-aligned ",
      "\e[33m#{symbols[:pipe]}\e[0m $1    \e[33m#{symbols[:pipe]}\e[0m \n",

      "\e[33m#{symbols[:bottom_left]}#{symbols[:line]*10}#{symbols[:bottom_center]}",
      "#{symbols[:line]*15}#{symbols[:bottom_center]}",
      "#{symbols[:line]*7}#{symbols[:bottom_right]}",
      "\e[0m\n"
    ].join)
  end

  it "wraps multiline records" do
    markdown =<<-TEXT
| Tables   |      Are      |  Cool |
|----------|:-------------:|------:|
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is a multiline column | right-aligned has also a very long content that wraps around |    $1 |
    TEXT

    parsed = TTY::Markdown.parse(markdown, width: 80)

    expected_output =
      "\e[33m#{symbols[:top_left]}#{symbols[:line]*24}#{symbols[:top_center]}" +
      "#{symbols[:line]*51}#{symbols[:top_center]}" +
      "#{symbols[:line]*7}#{symbols[:top_right]}" +
      "\e[0m\n" +

      "\e[33m#{symbols[:pipe]} \e[0mTables                 " +
      "\e[33m#{symbols[:pipe]}\e[0m                        Are                        " +
      "\e[33m#{symbols[:pipe]}\e[0m  Cool \e[33m#{symbols[:pipe]}\e[0m \n" +

      "\e[33m#{symbols[:mid_left]}#{symbols[:line]*24}#{symbols[:mid_center]}" +
      "#{symbols[:line]*51}#{symbols[:mid_center]}" +
      "#{symbols[:line]*7}#{symbols[:mid_right]}" +
      "\e[0m\n" +

      "\e[33m#{symbols[:pipe]} \e[0mcol 1 is               " +
      "\e[33m#{symbols[:pipe]}\e[0m                   left-aligned                    " +
      "\e[33m#{symbols[:pipe]}\e[0m $1600 \e[33m#{symbols[:pipe]}\e[0m \n" +

      "\e[33m#{symbols[:mid_left]}#{symbols[:line]*24}#{symbols[:mid_center]}" +
      "#{symbols[:line]*51}#{symbols[:mid_center]}" +
      "#{symbols[:line]*7}#{symbols[:mid_right]}" +
      "\e[0m\n" +

      "\e[33m#{symbols[:pipe]} \e[0mcol 2 is               " +
      "\e[33m#{symbols[:pipe]}\e[0m                     centered                      " +
      "\e[33m#{symbols[:pipe]}\e[0m   $12 \e[33m#{symbols[:pipe]}\e[0m \n" +

      "\e[33m#{symbols[:mid_left]}#{symbols[:line]*24}#{symbols[:mid_center]}" +
      "#{symbols[:line]*51}#{symbols[:mid_center]}" +
      "#{symbols[:line]*7}#{symbols[:mid_right]}" +
      "\e[0m\n" +

      "\e[33m#{symbols[:pipe]} \e[0mcol 3 is a multiline   " +
      "\e[33m#{symbols[:pipe]}\e[0m right-aligned has also a very long content that   " +
      "\e[33m#{symbols[:pipe]}\e[0m    $1 \e[33m#{symbols[:pipe]}\e[0m \n" +

      "\e[33m#{symbols[:pipe]} \e[0mcolumn                 " +
      "\e[33m#{symbols[:pipe]}\e[0m                   wraps around                    " +
      "\e[33m#{symbols[:pipe]}\e[0m       \e[33m#{symbols[:pipe]}\e[0m \n" +

      "\e[33m#{symbols[:bottom_left]}#{symbols[:line]*24}#{symbols[:bottom_center]}" +
      "#{symbols[:line]*51}#{symbols[:bottom_center]}" +
      "#{symbols[:line]*7}#{symbols[:bottom_right]}" +
      "\e[0m\n"

    expect(parsed).to eq(expected_output)
  end
end
