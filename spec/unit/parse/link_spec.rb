# frozen_string_literal: true

RSpec.describe TTY::Markdown, ".parse" do
  context "when Markdown" do
    context "when web address" do
      it "displays a link with text" do
        markdown = "[It's the TTY Toolkit](https://ttytoolkit.org)"
        parsed = described_class.parse(
          markdown, color: :always, symbols: :unicode
        )

        expect(parsed).to eq(
          "It’s the TTY Toolkit » \e[33;4mhttps://ttytoolkit.org\e[0m\n"
        )
      end

      it "displays a link with the text and title" do
        markdown = "[It's the TTY](https://ttytoolkit.org \"TTY's Homepage\")"
        parsed = described_class.parse(
          markdown, color: :always, symbols: :unicode
        )

        expect(parsed).to eq([
          "It’s the TTY » (TTY's Homepage) ",
          "\e[33;4mhttps://ttytoolkit.org\e[0m\n"
        ].join)
      end

      it "displays a link only when the text equals the destination" do
        markdown = "[https://ttytoolkit.org](https://ttytoolkit.org)"
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("\e[33;4mhttps://ttytoolkit.org\e[0m\n")
      end

      it "displays a link with a title when the text equals the destination" do
        markdown = "[https://ttytoolkit.org](https://ttytoolkit.org \"TTY\")"
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("(TTY) \e[33;4mhttps://ttytoolkit.org\e[0m\n")
      end

      it "displays nothing when the text is empty" do
        parsed = described_class.parse("[](https://ttytoolkit.org)")

        expect(parsed).to eq("\n")
      end

      it "displays nothing when the text is empty but the title is present" do
        parsed = described_class.parse("[](https://ttytoolkit.org \"TTY\")")

        expect(parsed).to eq("\n")
      end

      it "displays nothing when the text is just whitespace" do
        parsed = described_class.parse("[\n\t ](https://ttytoolkit.org)")

        expect(parsed).to eq("\n")
      end

      it "displays a link when marked with angle brackets" do
        markdown = "<https://ttytoolkit.org>"
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("\e[33;4mhttps://ttytoolkit.org\e[0m\n")
      end
    end

    context "when email address" do
      it "displays an email link with the mailto: prefix removed" do
        markdown = "[Email me](mailto:test@ttytoolkit.org)"
        parsed = described_class.parse(
          markdown, color: :always, symbols: :unicode
        )

        expect(parsed).to eq("Email me » \e[33;4mtest@ttytoolkit.org\e[0m\n")
      end

      it "displays an email link only when the text equals the address" do
        markdown = "[test@ttytoolkit.org](mailto:test@ttytoolkit.org)"
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("\e[33;4mtest@ttytoolkit.org\e[0m\n")
      end

      it "displays an email link when marked with angle brackets" do
        markdown = "<mailto:test@ttytoolkit.org>"
        parsed = described_class.parse(markdown, color: :always)

        expect(parsed).to eq("\e[33;4mtest@ttytoolkit.org\e[0m\n")
      end
    end
  end

  context "when HTML" do
    context "when web address" do
      it "displays a link with text when marked with the <a> element" do
        markdown = "<a href=\"https://ttytoolkit.org\">TTY Toolkit</a>"
        parsed = described_class.parse(
          markdown, color: :always, symbols: :unicode
        )

        expect(parsed).to eq(
          "TTY Toolkit » \e[33;4mhttps://ttytoolkit.org\e[0m\n"
        )
      end

      it "displays a link with the text and title marked with <a> element" do
        markdown = "<a href=\"https://ttytoolkit.org\" title=\"TTY\">TTY</a>"
        parsed = described_class.parse(
          markdown, color: :always, symbols: :unicode
        )

        expect(parsed).to eq(
          "TTY » (TTY) \e[33;4mhttps://ttytoolkit.org\e[0m\n"
        )
      end

      it "displays nothing when the text is empty inside the <a> element" do
        parsed = described_class.parse(
          "<a href=\"https://ttytoolkit.org\"></a>"
        )

        expect(parsed).to eq("\n")
      end
    end

    context "when email address" do
      it "displays an email link when marked with the <a> element" do
        markdown = "<a href=\"mailto:test@ttytoolkit.org\">Email me</a>"
        parsed = described_class.parse(
          markdown, color: :always, symbols: :unicode
        )

        expect(parsed).to eq("Email me » \e[33;4mtest@ttytoolkit.org\e[0m\n")
      end
    end
  end
end
