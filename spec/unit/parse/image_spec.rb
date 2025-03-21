# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "displays image title and source location" do
    markdown = <<-TEXT
![Code highlight](assets/headers.png)
    TEXT
    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq("\e[90m(Code highlight - assets/headers.png)\e[0m\n")
  end

  it "displays image with source location only" do
    markdown = <<-TEXT
![](assets/headers.png)
    TEXT
    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq("\e[90m(assets/headers.png)\e[0m\n")
  end

  it "converts html image element" do
    markdown = <<-TEXT
<img src="assets/headers.png" alt="Code highlight" />
    TEXT
    parsed = described_class.parse(markdown, color: :always)

    expect(parsed).to eq("\e[90m(Code highlight - assets/headers.png)\e[0m\n")
  end
end
