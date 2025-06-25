# frozen_string_literal: true

RSpec.describe TTY::Markdown::Color do
  describe "#initialize" do
    it "raises an error when the color is invalid" do
      expect {
        described_class.new(:unknown)
      }.to raise_error(
        TTY::Markdown::Error,
        "invalid color: :unknown. Use the :always, :auto or :never value."
      )
    end
  end

  describe "#to_enabled" do
    it "converts the always color to true" do
      color = described_class.new(:always)

      expect(color.to_enabled).to be(true)
    end

    it "converts the always color as a string to true" do
      color = described_class.new("always")

      expect(color.to_enabled).to be(true)
    end

    it "converts the auto color to nil" do
      color = described_class.new(:auto)

      expect(color.to_enabled).to be_nil
    end

    it "converts the auto color as a string to nil" do
      color = described_class.new("auto")

      expect(color.to_enabled).to be_nil
    end

    it "converts the never color to false" do
      color = described_class.new(:never)

      expect(color.to_enabled).to be(false)
    end

    it "converts the never color as a string to false" do
      color = described_class.new("never")

      expect(color.to_enabled).to be(false)
    end
  end
end
