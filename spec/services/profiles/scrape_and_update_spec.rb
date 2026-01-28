require "rails_helper"

RSpec.describe Profiles::ScrapeAndUpdate do
  let(:profile) { create(:profile) }
  let(:scraped_data) do
    {
      github_username: "newuser",
      followers_count: 200,
      following_count: 100,
      stars_count: 50,
      contributions_last_year: 500,
      avatar_url: "https://avatars.githubusercontent.com/u/456",
      organization: "New Org",
      location: "Rio de Janeiro"
    }
  end

  describe ".call" do
    context "when scraping succeeds" do
      before do
        allow(Github::ProfileScraper).to receive(:call).and_return(scraped_data)
      end

      it "updates profile with scraped data" do
        result = described_class.call(profile)

        profile.reload
        expect(profile.github_username).to eq("newuser")
        expect(profile.followers_count).to eq(200)
        expect(profile.following_count).to eq(100)
        expect(profile.stars_count).to eq(50)
        expect(profile.contributions_last_year).to eq(500)
        expect(profile.avatar_url).to eq("https://avatars.githubusercontent.com/u/456")
        expect(profile.organization).to eq("New Org")
        expect(profile.location).to eq("Rio de Janeiro")
        expect(profile.last_scanned_at).to be_present
      end

      it "returns success result" do
        result = described_class.call(profile)
        expect(result).to eq({ success: true, message: nil })
      end
    end

    context "when scraping fails" do
      let(:error_message) { "Network error" }

      before do
        allow(Github::ProfileScraper).to receive(:call).and_raise(
          Github::ProfileScraper::Error.new(error_message)
        )
        allow(Rails.logger).to receive(:error)
      end

      it "does not update profile" do
        original_username = profile.github_username
        described_class.call(profile)
        profile.reload
        expect(profile.github_username).to eq(original_username)
      end

      it "returns failure result" do
        result = described_class.call(profile)
        expect(result).to eq({ success: false, message: error_message })
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(
          /\[Profiles::ScrapeAndUpdate\].*#{profile.github_url}.*#{error_message}/
        )
        described_class.call(profile)
      end
    end
  end
end
