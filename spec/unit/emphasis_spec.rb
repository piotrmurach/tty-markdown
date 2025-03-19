# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "converts text marked with a single asterisk to colored text" do
    parsed = described_class.parse(
      "Some *easily noticeable* text", color: :always
    )

    expect(parsed).to eq("Some \e[33measily noticeable\e[0m text\n")
  end
end
