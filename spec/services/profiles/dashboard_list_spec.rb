# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::DashboardList do
  let(:user) { create(:user) }
  let!(:profile1) { create(:profile, user: user, name: "Profile 1", created_at: 2.days.ago) }
  let!(:profile2) { create(:profile, user: user, name: "Profile 2", created_at: 1.day.ago) }
  let!(:profile3) { create(:profile, user: user, name: "Other Profile", created_at: Time.current) }
  let!(:other_user_profile) { create(:profile, name: "Other User Profile") }

  describe ".call" do
    context "with default parameters" do
      it "returns user profiles ordered by created_at desc" do
        result = described_class.call(user: user)

        expect(result[:profiles].size).to eq(3)
        expect(result[:profiles].first).to eq(profile3)
        expect(result[:profiles].last).to eq(profile1)
      end

      it "returns only user profiles" do
        result = described_class.call(user: user)

        expect(result[:profiles]).to include(profile1, profile2, profile3)
        expect(result[:profiles]).not_to include(other_user_profile)
      end

      it "returns default pagination" do
        result = described_class.call(user: user)

        expect(result[:profiles].current_page).to eq(1)
        expect(result[:profiles].per_page).to eq(10)
      end

      it "returns normalized query as nil" do
        result = described_class.call(user: user)
        expect(result[:query]).to be_nil
      end
    end

    context "with search query" do
      it "filters profiles by query" do
        result = described_class.call(user: user, query: "Profile 1")

        expect(result[:profiles]).to include(profile1)
        expect(result[:profiles]).not_to include(profile2, profile3)
      end

      it "normalizes query with strip" do
        result = described_class.call(user: user, query: "  Profile 1  ")

        expect(result[:query]).to eq("Profile 1")
        expect(result[:profiles]).to include(profile1)
      end

      it "returns nil for empty query" do
        result = described_class.call(user: user, query: "   ")

        expect(result[:query]).to be_nil
      end
    end

    context "with pagination" do
      before do
        create_list(:profile, 15, user: user)
      end

      it "paginates results" do
        result = described_class.call(user: user, page: 1, per_page: 10)

        expect(result[:profiles].size).to eq(10)
        expect(result[:profiles].current_page).to eq(1)
      end

      it "returns second page" do
        result = described_class.call(user: user, page: 2, per_page: 10)

        expect(result[:profiles].current_page).to eq(2)
        expect(result[:profiles].size).to be <= 10
        expect(result[:profiles].size).to be > 0
      end
    end

    context "with custom per_page" do
      it "respects per_page parameter" do
        result = described_class.call(user: user, per_page: 2)

        expect(result[:profiles].per_page).to eq(2)
        expect(result[:profiles].size).to eq(2)
      end

      it "limits to MAX_PER_PAGE" do
        result = described_class.call(user: user, per_page: 100)

        expect(result[:profiles].per_page).to eq(50)
      end
    end

    context "with invalid page" do
      it "defaults to page 1" do
        result = described_class.call(user: user, page: 0)
        expect(result[:profiles].current_page).to eq(1)

        result = described_class.call(user: user, page: -1)
        expect(result[:profiles].current_page).to eq(1)

        result = described_class.call(user: user, page: "invalid")
        expect(result[:profiles].current_page).to eq(1)
      end
    end

    context "with invalid per_page" do
      it "defaults to DEFAULT_PER_PAGE" do
        result = described_class.call(user: user, per_page: 0)
        expect(result[:profiles].per_page).to eq(10)

        result = described_class.call(user: user, per_page: -1)
        expect(result[:profiles].per_page).to eq(10)

        result = described_class.call(user: user, per_page: "invalid")
        expect(result[:profiles].per_page).to eq(10)
      end
    end

    context "when user has no profiles" do
      let(:empty_user) { create(:user) }

      it "returns empty collection" do
        result = described_class.call(user: empty_user)

        expect(result[:profiles].size).to eq(0)
      end
    end

    context "with numeric search query" do
      let!(:profile_with_followers) do
        create(:profile, user: user, followers_count: 1000)
      end

      it "searches by numeric fields" do
        result = described_class.call(user: user, query: "1000")

        expect(result[:profiles]).to include(profile_with_followers)
      end
    end
  end
end
