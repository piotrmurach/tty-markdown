# frozen_string_literal: true

RSpec.describe TTY::Markdown::Symbols do
  describe ".from" do
    context "when ASCII" do
      let(:name) { :ascii }

      it "selects symbols with a name" do
        symbols = described_class.from(name)

        expect(symbols[:arrow]).to eq("->")
      end

      it "selects symbols with a name as a string" do
        symbols = described_class.from(name.to_s)

        expect(symbols[:arrow]).to eq("->")
      end

      it "selects symbols with a base" do
        symbols = described_class.from({base: name})

        expect(symbols[:arrow]).to eq("->")
      end

      it "selects symbols with a base as a string" do
        symbols = described_class.from({base: name.to_s})

        expect(symbols[:arrow]).to eq("->")
      end

      it "overrides symbols with a base" do
        symbols = described_class.from({
          base: name,
          override: {
            arrow: "=>"
          }
        })

        expect([symbols[:arrow], symbols[:bullet]]).to eq(["=>", "*"])
      end
    end

    context "when Unicode" do
      let(:name) { :unicode }

      it "selects symbols with a name" do
        symbols = described_class.from(name)

        expect(symbols[:arrow]).to eq("»")
      end

      it "selects symbols with a name as a string" do
        symbols = described_class.from(name.to_s)

        expect(symbols[:arrow]).to eq("»")
      end

      it "selects symbols with a base" do
        symbols = described_class.from({base: name})

        expect(symbols[:arrow]).to eq("»")
      end

      it "selects symbols with a base as a string" do
        symbols = described_class.from({base: name.to_s})

        expect(symbols[:arrow]).to eq("»")
      end

      it "overrides symbols with a base" do
        symbols = described_class.from({
          base: name,
          override: {
            arrow: "=>"
          }
        })

        expect([symbols[:arrow], symbols[:bullet]]).to eq(["=>", "●"])
      end

      it "overrides symbols without a base" do
        symbols = described_class.from({
          override: {
            arrow: "=>"
          }
        })

        expect([symbols[:arrow], symbols[:bullet]]).to eq(["=>", "●"])
      end
    end

    context "when nil" do
      let(:name) { nil }

      it "raises an error when selecting symbols with a name" do
        expect {
          described_class.from(name)
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbols: nil. " \
          "Use a hash with base and override keys or a symbol."
        )
      end

      it "raises an error when selecting symbols with a base" do
        expect {
          described_class.from({base: name})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbols name: nil. Use the :ascii or :unicode name."
        )
      end
    end

    context "when empty string" do
      let(:name) { "" }

      it "raises an error when selecting symbols with a name" do
        expect {
          described_class.from(name)
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbols name: \"\". Use the :ascii or :unicode name."
        )
      end

      it "raises an error when selecting symbols with a base" do
        expect {
          described_class.from({base: name})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbols name: \"\". Use the :ascii or :unicode name."
        )
      end
    end

    context "when unknown" do
      let(:name) { :unknown }

      it "raises an error when selecting symbols with a name" do
        expect {
          described_class.from(name)
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbols name: :unknown. Use the :ascii or :unicode name."
        )
      end

      it "raises an error when selecting symbols with a base" do
        expect {
          described_class.from({base: name})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbols name: :unknown. Use the :ascii or :unicode name."
        )
      end

      it "raises an error when overriding a symbol" do
        expect {
          described_class.from({override: {name => "=>"}})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbol name: :unknown."
        )
      end

      it "raises an error when overriding symbols" do
        expect {
          described_class.from({override: {other: "x", name => "=>"}})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbol names: :other, :unknown."
        )
      end
    end

    context "when empty hash" do
      let(:name) { {} }

      it "selects Unicode symbols with a name" do
        symbols = described_class.from(name)

        expect(symbols[:arrow]).to eq("»")
      end

      it "raises an error when selecting symbols with a base" do
        expect {
          described_class.from({base: name})
        }.to raise_error(
          TTY::Markdown::Error,
          "invalid symbols name: {}. Use the :ascii or :unicode name."
        )
      end
    end
  end

  describe "#[]" do
    it "fetches a symbol by name" do
      symbols = described_class.from(:ascii)

      expect(symbols[:arrow]).to eq("->")
    end

    it "raises an error when fetching a symbol by name as a string" do
      symbols = described_class.from(:ascii)

      expect {
        symbols["arrow"]
      }.to raise_error(
        TTY::Markdown::Error,
        "invalid symbol name: \"arrow\"."
      )
    end

    it "raises an error when fetching a symbol by an unknown name" do
      symbols = described_class.from(:ascii)

      expect {
        symbols[:unknown]
      }.to raise_error(
        TTY::Markdown::Error,
        "invalid symbol name: :unknown."
      )
    end
  end

  describe "#wrap_in_brackets" do
    subject(:symbols) { described_class.from(name) }

    context "when ASCII" do
      let(:name) { :ascii }

      it "wraps nil in brackets" do
        expect(symbols.wrap_in_brackets(nil)).to eq("[]")
      end

      it "wraps an empty string in brackets" do
        expect(symbols.wrap_in_brackets("")).to eq("[]")
      end

      it "wraps content in brackets" do
        expect(symbols.wrap_in_brackets("TTY Toolkit")).to eq("[TTY Toolkit]")
      end
    end

    context "when Unicode" do
      let(:name) { :unicode }

      it "wraps nil in brackets" do
        expect(symbols.wrap_in_brackets(nil)).to eq("[]")
      end

      it "wraps an empty string in brackets" do
        expect(symbols.wrap_in_brackets("")).to eq("[]")
      end

      it "wraps content in brackets" do
        expect(symbols.wrap_in_brackets("TTY Toolkit")).to eq("[TTY Toolkit]")
      end
    end
  end
end
