require "rails_helper"

RSpec.describe Profile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:github_url) }
    it "validates uniqueness of short_code when present" do
      existing_profile = create(:profile, short_code: "abc123")
      new_profile = build(:profile, short_code: "abc123")
      expect(new_profile).not_to be_valid
    end

    it "allows nil short_code" do
      profile = build(:profile, short_code: nil)
      expect(profile).to be_valid
    end

    context "github_url format" do
      it "accepts valid GitHub URLs" do
        profile = build(:profile, github_url: "https://github.com/user")
        expect(profile).to be_valid
      end

      it "accepts GitHub URLs with www" do
        profile = build(:profile, github_url: "https://www.github.com/user")
        expect(profile).to be_valid
      end

      it "rejects invalid URLs" do
        profile = build(:profile, github_url: "https://gitlab.com/user")
        expect(profile).not_to be_valid
      end

      it "rejects non-HTTP URLs" do
        profile = build(:profile, github_url: "github.com/user")
        expect(profile).not_to be_valid
      end
    end
  end

  describe "scopes" do
    describe ".search" do
      let(:user) { create(:user) }
      let!(:profile1) { create(:profile, user: user, name: "João Silva", github_username: "joao") }
      let!(:profile2) { create(:profile, user: user, name: "Maria Santos", location: "São Paulo") }
      let!(:profile3) { create(:profile, user: user, organization: "Tech Corp", followers_count: 100) }

      it "returns all profiles when query is blank" do
        expect(Profile.search(nil).count).to eq(3)
        expect(Profile.search("").count).to eq(3)
      end

      it "searches by name" do
        results = Profile.search("João")
        expect(results).to include(profile1)
        expect(results).not_to include(profile2)
      end

      it "searches by github_username" do
        results = Profile.search("joao")
        expect(results).to include(profile1)
      end

      it "searches by location" do
        results = Profile.search("São Paulo")
        expect(results).to include(profile2)
      end

      it "searches by organization" do
        results = Profile.search("Tech Corp")
        expect(results).to include(profile3)
      end

      it "searches by numeric values" do
        results = Profile.search("100")
        expect(results).to include(profile3)
      end

      it "is case insensitive" do
        results = Profile.search("JOÃO")
        expect(results).to include(profile1)
      end
    end
  end

  describe "#short_github_url" do
    let(:profile) { create(:profile, short_code: "abc123") }

    it "returns nil when short_code is blank" do
      profile.short_code = nil
      expect(profile.short_github_url).to be_nil
    end

    it "returns the shortened URL when short_code is present" do
      expect(profile.short_github_url).to include("abc123")
    end
  end

  describe "#organizations_array" do
    it "returns empty array when organization is blank" do
      profile = build(:profile, organization: nil)
      expect(profile.organizations_array).to eq([])
    end

    it "returns array with organization when present" do
      profile = build(:profile, organization: "Tech Corp")
      expect(profile.organizations_array).to eq(["Tech Corp"])
    end
  end
end
