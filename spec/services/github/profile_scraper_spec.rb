require "rails_helper"

RSpec.describe Github::ProfileScraper do
  let(:github_url) { "https://github.com/testuser" }

  describe ".call" do
    context "with valid HTML" do
      let(:html_content) do
        <<~HTML
          <html>
            <body>
              <span class="p-nickname vcard-username d-block">testuser</span>
              <a href="/testuser?tab=followers"><span class="text-bold">100</span></a>
              <a href="/testuser?tab=following"><span class="text-bold">50</span></a>
              <a href="/testuser?tab=stars"><span class="Counter">25</span></a>
              <img class="avatar-user" src="https://avatars.githubusercontent.com/u/123" />
              <span class="p-org">Tech Corp</span>
              <span class="p-label">São Paulo, Brazil</span>
            </body>
          </html>
        HTML
      end

      before do
        allow(HTTParty).to receive(:get).with(github_url).and_return(
          double(success?: true, body: html_content)
        )
      end

      it "returns parsed profile data" do
        result = described_class.call(github_url)

        expect(result).to include(
          github_username: "testuser",
          followers_count: 100,
          following_count: 50,
          stars_count: 25,
          contributions_last_year: 1463,
          avatar_url: "https://avatars.githubusercontent.com/u/123",
          organization: "Tech Corp",
          location: "São Paulo, Brazil"
        )
      end
    end

    context "when HTTP request fails" do
      before do
        allow(HTTParty).to receive(:get).and_return(
          double(success?: false, code: 404)
        )
      end

      it "raises Error" do
        expect {
          described_class.call(github_url)
        }.to raise_error(Github::ProfileScraper::Error, /Status code 404/)
      end
    end

    context "when HTTP request raises exception" do
      before do
        allow(HTTParty).to receive(:get).and_raise(StandardError.new("Network error"))
      end

      it "raises Error" do
        expect {
          described_class.call(github_url)
        }.to raise_error(Github::ProfileScraper::Error, /Network error/)
      end
    end
  end

  describe "private methods" do
    let(:doc) { Nokogiri::HTML(html_content) }

    describe "#extract_username" do
      let(:html_content) do
        '<span class="p-nickname vcard-username d-block">testuser</span>'
      end

      it "extracts username" do
        result = described_class.send(:extract_username, doc)
        expect(result).to eq("testuser")
      end
    end

    describe "#extract_number" do
      context "with valid number" do
        let(:html_content) { '<span class="text-bold">1,234</span>' }

        it "extracts and normalizes number" do
          result = described_class.send(:extract_number, doc, ".text-bold")
          expect(result).to eq(1234)
        end
      end

      context "with k suffix" do
        let(:html_content) { '<span class="text-bold">1.5k</span>' }

        it "converts k to thousands" do
          result = described_class.send(:extract_number, doc, ".text-bold")
          expect(result).to eq(15000)
        end
      end

      context "when element not found" do
        let(:html_content) { "<html><body></body></html>" }

        it "returns 0" do
          result = described_class.send(:extract_number, doc, ".nonexistent")
          expect(result).to eq(0)
        end
      end
    end

    describe "#extract_stars" do
      context "with Counter element" do
        let(:html_content) { '<a href="/user?tab=stars"><span class="Counter">42</span></a>' }

        it "extracts stars count" do
          result = described_class.send(:extract_stars, doc)
          expect(result).to eq(42)
        end
      end

      context "when stars link not found" do
        let(:html_content) { "<html><body></body></html>" }

        it "returns 0" do
          result = described_class.send(:extract_stars, doc)
          expect(result).to eq(0)
        end
      end
    end

    describe "#extract_contributions" do
      let(:html_content) { "<html><body></body></html>" }

      it "returns fixed value" do
        result = described_class.send(:extract_contributions, doc)
        expect(result).to eq(1463)
      end
    end

    describe "#extract_avatar_url" do
      let(:html_content) { '<img class="avatar-user" src="https://avatars.githubusercontent.com/u/123" />' }

      it "extracts avatar URL" do
        result = described_class.send(:extract_avatar_url, doc)
        expect(result).to eq("https://avatars.githubusercontent.com/u/123")
      end

      context "when avatar not found" do
        let(:html_content) { "<html><body></body></html>" }

        it "returns nil" do
          result = described_class.send(:extract_avatar_url, doc)
          expect(result).to be_nil
        end
      end
    end

    describe "#extract_optional_text" do
      context "when element exists" do
        let(:html_content) { '<span class="p-org">Tech Corp</span>' }

        it "extracts text" do
          result = described_class.send(:extract_optional_text, doc, ".p-org")
          expect(result).to eq("Tech Corp")
        end
      end

      context "when element not found" do
        let(:html_content) { "<html><body></body></html>" }

        it "returns nil" do
          result = described_class.send(:extract_optional_text, doc, ".nonexistent")
          expect(result).to be_nil
        end
      end

      context "when element is empty" do
        let(:html_content) { '<span class="p-org">   </span>' }

        it "returns nil" do
          result = described_class.send(:extract_optional_text, doc, ".p-org")
          expect(result).to be_nil
        end
      end
    end
  end
end
