# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "converts text marked with a double asterisk to bold and colored text" do
    parsed = described_class.parse(
      "Some **strongly important** text", color: :always
    )

    expect(parsed).to eq("Some \e[33;1mstrongly important\e[0m text\n")
  end
end
