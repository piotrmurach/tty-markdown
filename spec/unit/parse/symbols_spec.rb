# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'symbols' do
  let(:pastel) { Pastel.new }

  it "defaults to unicode symbols" do
    markdown = "- example"
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("#{pastel.yellow(TTY::Markdown::SYMBOLS[:bullet])} example\n")
  end

  it "responds to simple :ascii option" do
    markdown = "- example"
    parsed = TTY::Markdown.parse(markdown, symbols: :ascii)
    expect(parsed).to eq("#{pastel.yellow(TTY::Markdown::ASCII_SYMBOLS[:bullet])} example\n")
  end

  it "responds to :ascii specified as base in hash" do
    markdown = "- example"
    parsed = TTY::Markdown.parse(markdown, symbols: {base: :ascii})
    expect(parsed).to eq("#{pastel.yellow(TTY::Markdown::ASCII_SYMBOLS[:bullet])} example\n")
  end

  it "overrides individual symbols" do
    markdown = "- example"
    parsed = TTY::Markdown.parse(markdown, symbols: {override: {bullet: "x"}})
    expect(parsed).to eq("#{pastel.yellow("x")} example\n")
  end
end
