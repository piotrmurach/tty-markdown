# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  let(:pastel) { Pastel.new(enabled: true) }

  it "defaults to the built-in theme when not provided" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq("#{pastel.yellow("●")} example » " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "defaults to the built-in theme when nil" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always, theme: nil)

    expect(parsed).to eq("#{pastel.yellow("●")} example » " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "defaults to the built-in theme when provided an empty hash" do
    markdown = "- [example](example.com)"
    parsed = described_class.parse(markdown, color: :always, theme: {})

    expect(parsed).to eq("#{pastel.yellow("●")} example » " \
                         "#{pastel.yellow.underline("example.com")}\n")
  end

  it "overrides specific theme elements with style values as symbols" do
    markdown = "- [*example*](example.com)"
    parsed = described_class.parse(
      markdown,
      color: :always,
      theme: {
        link: :magenta,
        list: %i[green bold]
      }
    )

    expect(parsed).to eq("#{pastel.green.bold("●")} " \
                         "#{pastel.yellow("example")} » " \
                         "#{pastel.magenta("example.com")}\n")
  end

  it "overrides specific theme elements with style values as strings" do
    markdown = "- [*example*](example.com)"
    parsed = described_class.parse(
      markdown,
      color: :always,
      symbols: :ascii,
      theme: {
        link: "magenta",
        list: %w[green bold]
      }
    )

    expect(parsed).to eq("#{pastel.green.bold("*")} " \
                         "#{pastel.yellow("example")} -> " \
                         "#{pastel.magenta("example.com")}\n")
  end
end
