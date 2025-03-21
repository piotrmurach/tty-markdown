# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  it "doesn't convert text marked with a double tilde" do
    parsed = described_class.parse(
      "Some ~~permanently deleted~~ text", color: :always
    )

    expect(parsed).to eq("Some ~~permanently deleted~~ text\n")
  end
end
