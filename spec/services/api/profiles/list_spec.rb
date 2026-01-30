# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Profiles::List do
  describe ".call" do
    let(:user) { create(:user) }
    
    before do
      create_list(:profile, 25, user: user)
    end

    context "with default parameters" do
      it "returns first page with default per_page" do
        result = described_class.call(user: user)

        expect(result).to be_a(Hash)
        expect(result[:profiles]).to respond_to(:current_page)
        expect(result[:profiles]).to respond_to(:per_page)
        expect(result[:profiles].current_page).to eq(1)
        expect(result[:profiles].per_page).to eq(10)
        expect(result[:profiles].size).to eq(10)
        expect(result[:meta]).to include(
          current_page: 1,
          per_page: 10,
          total_pages: 3,
          total_count: 25
        )
        expect(result[:profiles].all? { |p| p.user_id == user.id }).to be true
      end
    end

    context "with custom page" do
      it "returns the specified page" do
        result = described_class.call(user: user, page: 2)

        expect(result[:profiles].current_page).to eq(2)
        expect(result[:meta][:current_page]).to eq(2)
      end
    end

    context "with custom per_page" do
      it "returns the specified per_page" do
        result = described_class.call(user: user, per_page: 5)

        expect(result[:profiles].per_page).to eq(5)
        expect(result[:profiles].size).to eq(5)
        expect(result[:meta][:per_page]).to eq(5)
        expect(result[:meta][:total_pages]).to eq(5)
      end
    end

    context "with per_page exceeding maximum" do
      it "limits to MAX_PER_PAGE" do
        result = described_class.call(user: user, per_page: 200)

        expect(result[:profiles].per_page).to eq(100)
        expect(result[:meta][:per_page]).to eq(100)
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
        expect(result[:meta][:per_page]).to eq(10)

        result = described_class.call(user: user, per_page: -1)
        expect(result[:profiles].per_page).to eq(10)
        expect(result[:meta][:per_page]).to eq(10)

        result = described_class.call(user: user, per_page: "invalid")
        expect(result[:profiles].per_page).to eq(10)
        expect(result[:meta][:per_page]).to eq(10)
      end
    end

    context "with string parameters" do
      it "converts strings to integers" do
        result = described_class.call(user: user, page: "2", per_page: "5")

        expect(result[:profiles].current_page).to eq(2)
        expect(result[:profiles].per_page).to eq(5)
      end
    end

    context "when no profiles exist" do
      let(:empty_user) { create(:user) }

      it "returns empty collection with correct meta" do
        result = described_class.call(user: empty_user)

        expect(result[:profiles].size).to eq(0)
        expect(result[:meta][:current_page]).to eq(1)
        expect(result[:meta][:per_page]).to eq(10)
        expect(result[:meta][:total_count]).to eq(0)
        expect(result[:meta][:total_pages]).to be >= 0
      end
    end
  end
end
