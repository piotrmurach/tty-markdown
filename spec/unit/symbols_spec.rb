# frozen_string_literal: true

RSpec.describe TTY::Markdown, "symbols" do
  let(:pastel) { Pastel.new(enabled: true) }

  it "defaults to unicode symbols when not provided" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq("#{pastel.yellow("●")} example » " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "defaults to unicode symbols when nil" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: nil)

    expect(parsed).to eq("#{pastel.yellow("●")} example » " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "defaults to unicode symbols when provided an empty hash" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: {})

    expect(parsed).to eq("#{pastel.yellow("●")} example » " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "accepts an ascii value as a symbol" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: :ascii)

    expect(parsed).to eq("#{pastel.yellow("*")} example -> " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "accepts an ascii value as a string" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always, symbols: "ascii")

    expect(parsed).to eq("#{pastel.yellow("*")} example -> " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "accepts an ascii value specified with a base key in a hash" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always,
                                             symbols: {base: :ascii})

    expect(parsed).to eq("#{pastel.yellow("*")} example -> " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "overrides specific symbols with an override key in a hash" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always,
                                             symbols: {
                                               override: {bullet: "x"}
                                             })

    expect(parsed).to eq("#{pastel.yellow("x")} example » " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "overrides specific symbols with an ascii base in a hash" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always,
                                             symbols: {
                                               base: "ascii",
                                               override: {bullet: "x"}
                                             })

    expect(parsed).to eq("#{pastel.yellow("x")} example -> " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end
end
