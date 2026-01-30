require "rails_helper"

RSpec.describe Github::ContributionsClient do
  describe ".fetch" do
    let(:username) { "testuser" }
    let(:token) { "test_token_123" }
    let(:endpoint) { "https://api.github.com/graphql" }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("API_TOKEN").and_return(token)
    end

    context "with successful API response" do
      let(:response_body) do
        {
          "data" => {
            "user" => {
              "contributionsCollection" => {
                "contributionCalendar" => {
                  "totalContributions" => 1463
                }
              }
            }
          }
        }
      end

      before do
        allow(HTTParty).to receive(:post).and_return(response_body)
      end

      it "returns total contributions" do
        result = described_class.fetch(username)
        expect(result).to eq(1463)
      end
    end

    context "when API response has no data" do
      before do
        allow(HTTParty).to receive(:post).and_return({})
      end

      it "returns 0" do
        result = described_class.fetch(username)
        expect(result).to eq(0)
      end
    end

    context "when API raises an error" do
      before do
        allow(HTTParty).to receive(:post).and_raise(StandardError.new("Network error"))
      end

      it "returns 0" do
        result = described_class.fetch(username)
        expect(result).to eq(0)
      end
    end

    context "when API_TOKEN is not set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("API_TOKEN").and_return(nil)
        allow(HTTParty).to receive(:post).and_raise(StandardError.new("Unauthorized"))
      end

      it "returns 0" do
        result = described_class.fetch(username)
        expect(result).to eq(0)
      end
    end
  end
end
