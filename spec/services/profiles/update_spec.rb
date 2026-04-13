# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Update do
  let(:profile) { create(:profile, name: "Old Name", github_url: "https://github.com/olduser") }
  let(:profile_params) do
    {
      name: "New Name",
      github_url: "https://github.com/newuser"
    }
  end

  describe ".call" do
    context "when update succeeds" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_return("jid-123")
      end

      it "updates profile attributes" do
        result = described_class.call(profile: profile, profile_params: profile_params)
        
        profile.reload
        expect(profile.name).to eq("New Name")
        expect(profile.github_url).to eq("https://github.com/newuser")
      end

      it "enqueues ScrapeAndUpdateJob" do
        expect(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).once.with(profile.id)
        described_class.call(profile: profile, profile_params: profile_params)
      end

      it "returns success result" do
        result = described_class.call(profile: profile, profile_params: profile_params)
        
        expect(result[:success]).to be true
        expect(result[:profile]).to eq(profile)
        expect(result[:scrape_success]).to be true
        expect(result[:scrape_message]).to eq("Extração de dados do Github enfileirada.")
      end
    end

    context "when enqueuing succeeds" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_return("jid-123")
      end

      it "returns scrape_success as true" do
        result = described_class.call(profile: profile, profile_params: profile_params)
        expect(result[:scrape_success]).to be true
      end
    end

    context "when enqueuing succeeds" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_return("jid-123")
      end

      it "still updates the profile" do
        result = described_class.call(profile: profile, profile_params: profile_params)
        
        profile.reload
        expect(profile.name).to eq("New Name")
      end

      it "returns scrape_success as true" do
        result = described_class.call(profile: profile, profile_params: profile_params)
        expect(result[:scrape_success]).to be true
        expect(result[:scrape_message]).to eq("Extração de dados do Github enfileirada.")
      end
    end

    context "when profile validation fails" do
      let(:invalid_params) do
        {
          name: "",
          github_url: "invalid-url"
        }
      end

      it "does not update the profile" do
        original_name = profile.name
        result = described_class.call(profile: profile, profile_params: invalid_params)
        
        profile.reload
        expect(profile.name).to eq(original_name)
      end

      it "returns failure result with errors" do
        result = described_class.call(profile: profile, profile_params: invalid_params)
        
        expect(result[:success]).to be false
        expect(result[:profile]).to eq(profile)
        expect(result[:profile].errors).to be_present
        expect(result[:errors]).to be_present
      end

      it "does not enqueue ScrapeAndUpdateJob" do
        expect(Profiles::ScrapeAndUpdateJob).not_to receive(:perform_async)
        described_class.call(profile: profile, profile_params: invalid_params)
      end
    end

    context "when an exception occurs" do
      before do
        allow(profile).to receive(:update).and_raise(StandardError.new("Database error"))
        allow(Rails.logger).to receive(:error)
      end

      it "returns failure result" do
        result = described_class.call(profile: profile, profile_params: profile_params)
        
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Database error")
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/\[Profiles::Update\] Error: Database error/)
        expect(Rails.logger).to receive(:error).with(anything)
        described_class.call(profile: profile, profile_params: profile_params)
      end

      it "does not update the profile" do
        original_name = profile.name
        described_class.call(profile: profile, profile_params: profile_params)
        
        profile.reload
        expect(profile.name).to eq(original_name)
      end
    end

    context "when enqueuing raises an exception" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_raise(StandardError.new("Queue error"))
        allow(Rails.logger).to receive(:error)
      end

      it "keeps profile update and returns failure payload" do
        result = described_class.call(profile: profile, profile_params: profile_params)

        profile.reload
        expect(profile.name).to eq("New Name")
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Queue error")
      end
    end
  end
end
