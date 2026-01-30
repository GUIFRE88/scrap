# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfileRepository do
  let(:user) { create(:user) }
  let(:repository) { described_class.new }

  describe "#save" do
    let(:profile) { build(:profile, user: user) }

    context "when profile is valid" do
      it "saves the profile" do
        expect(repository.save(profile)).to be true
        expect(profile).to be_persisted
      end
    end

    context "when profile is invalid" do
      let(:profile) { build(:profile, user: user, name: nil) }

      it "returns false" do
        expect(repository.save(profile)).to be false
        expect(profile).not_to be_persisted
      end
    end
  end

  describe "#update" do
    let(:profile) { create(:profile, user: user, name: "Old Name") }

    context "when update is valid" do
      it "updates the profile" do
        expect(repository.update(profile, name: "New Name")).to be true
        expect(profile.reload.name).to eq("New Name")
      end
    end

    context "when update is invalid" do
      it "returns false" do
        expect(repository.update(profile, name: nil)).to be false
        expect(profile.reload.name).to eq("Old Name")
      end
    end
  end

  describe "#update!" do
    let(:profile) { create(:profile, user: user, name: "Old Name") }

    context "when update is valid" do
      it "updates the profile" do
        expect { repository.update!(profile, name: "New Name") }.not_to raise_error
        expect(profile.reload.name).to eq("New Name")
      end
    end

    context "when update is invalid" do
      it "raises an error" do
        expect { repository.update!(profile, name: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#destroy" do
    let(:profile) { create(:profile, user: user) }

    it "destroys the profile" do
      profile_id = profile.id
      repository.destroy(profile)
      expect(Profile.exists?(profile_id)).to be false
    end
  end

  describe "#build" do
    let(:attributes) { { name: "Test Profile", github_url: "https://github.com/test" } }

    it "builds a new profile" do
      profile = repository.build(user, attributes)
      
      expect(profile).to be_a(Profile)
      expect(profile).not_to be_persisted
      expect(profile.user).to eq(user)
      expect(profile.name).to eq("Test Profile")
      expect(profile.github_url).to eq("https://github.com/test")
    end
  end

  describe "#find" do
    let(:profile) { create(:profile, user: user) }

    it "finds the profile by id" do
      found_profile = repository.find(profile.id)
      expect(found_profile).to eq(profile)
    end

    context "when profile does not exist" do
      it "raises an error" do
        expect { repository.find(999999) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#exists?" do
    before do
      create(:profile, user: user, short_code: "abc123")
    end

    context "when profile exists" do
      it "returns true" do
        expect(repository.exists?(short_code: "abc123")).to be true
      end
    end

    context "when profile does not exist" do
      it "returns false" do
        expect(repository.exists?(short_code: "nonexistent")).to be false
      end
    end
  end

  describe "#paginate" do
    before do
      15.times { create(:profile) }
    end

    it "returns paginated profiles" do
      result = repository.paginate(page: 1, per_page: 10)
      
      expect(result).to respond_to(:current_page)
      expect(result).to respond_to(:total_pages)
      expect(result).to respond_to(:total_entries)
      expect(result.size).to be <= 10
      expect(result.current_page).to eq(1)
      expect(result.per_page).to eq(10)
    end

    it "respects page parameter" do
      page1 = repository.paginate(page: 1, per_page: 10)
      page2 = repository.paginate(page: 2, per_page: 10)
      
      expect(page1.current_page).to eq(1)
      expect(page2.current_page).to eq(2)
      expect(page1.size).to be <= 10
      expect(page2.size).to be <= 10
      expect(page1.map(&:id)).not_to eq(page2.map(&:id))
    end
  end

  describe "#user_profiles" do
    let(:other_user) { create(:user) }

    before do
      create(:profile, user: user)
      create(:profile, user: user)
      create(:profile, user: other_user)
    end

    it "returns profiles for the given user" do
      profiles = repository.user_profiles(user)
      
      expect(profiles.count).to eq(2)
      expect(profiles.all? { |p| p.user == user }).to be true
    end
  end
end
