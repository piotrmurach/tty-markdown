# frozen_string_literal: true

RSpec.describe TTY::Markdown, 'entity' do
  it "converts html entities" do
    markdown =<<-TEXT
&copy; 2018 by me and &#x3bb;
    TEXT
    parsed = TTY::Markdown.parse(markdown)
    expect(parsed).to eq("© 2018 by me and λ\n")
  end
end
