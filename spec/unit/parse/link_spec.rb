# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "displays link with label" do
    markdown = <<-TEXT
[I'm an inline-style link](https://www.google.com)
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "I’m an inline-style link » ",
      "\e[33;4mhttps://www.google.com\e[0m\n"
    ].join)
  end

  it "displays link with label and title" do
    markdown = <<-TEXT
[I'm an inline-style link with title](https://www.google.com "Google's Homepage")
    TEXT
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq([
      "I’m an inline-style link with title » ",
      "(Google's Homepage) \e[33;4mhttps://www.google.com\e[0m\n"
    ].join)
  end

  it "displays a link with a title when text equals destination" do
    markdown = "[https://ttytoolkit.org](https://ttytoolkit.org \"TTY\")"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("(TTY) \e[33;4mhttps://ttytoolkit.org\e[0m\n")
  end

  it "displays email links with mailto: prefix removed" do
    markdown = "[Email me](mailto:test@example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("Email me » \e[33;4mtest@example.com\e[0m\n")
  end

  it "displays email links without label when label matches address" do
    markdown = "[test@example.com](mailto:test@example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\e[33;4mtest@example.com\e[0m\n")
  end

  it "displays nothing when label is empty" do
    markdown = "[](https://example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\n")
  end

  it "displays nothing when label is empty but title is present" do
    markdown = "[](https://example.com \"Title\")"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\n")
  end

  it "displays nothing when label is just whitespace" do
    markdown = "[\n\t ](https://example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\n")
  end

  it "displays link without displaying label when label matches link target" do
    markdown = "[https://example.com](https://example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\e[33;4mhttps://example.com\e[0m\n")
  end

  it "displays typical autolinks without displaying label" do
    markdown = "<https://example.com>"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\e[33;4mhttps://example.com\e[0m\n")
  end

  it "displays email autolinks without displaying label" do
    markdown = "<mailto:test@example.com>"
    parsed = described_class.parse(markdown, color: :always, symbols: :unicode)

    expect(parsed).to eq("\e[33;4mtest@example.com\e[0m\n")
  end
end
