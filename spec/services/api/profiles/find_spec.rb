# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Profiles::Find do
  describe ".call" do
    let(:profile) { create(:profile) }

    context "when profile exists" do
      it "returns the profile and meta information" do
        result = described_class.call(id: profile.id)

        expect(result).to be_a(Hash)
        expect(result[:profile]).to eq(profile)
        expect(result[:meta]).to eq({
          current_page: 1,
          per_page: 1,
          total_pages: 1,
          total_count: 1
        })
      end
    end

    context "when profile does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.call(id: 99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when called multiple times" do
      it "returns the same profile" do
        result1 = described_class.call(id: profile.id)
        result2 = described_class.call(id: profile.id)

        expect(result1[:profile]).to eq(result2[:profile])
        expect(result1[:profile].id).to eq(result2[:profile].id)
      end
    end
  end
end
