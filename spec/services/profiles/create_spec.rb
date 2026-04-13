# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Create do
  let(:user) { create(:user) }
  let(:profile_params) do
    {
      name: "Test User",
      github_url: "https://github.com/testuser"
    }
  end

  describe ".call" do
    context "when profile creation succeeds" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_return("jid-123")
      end

      it "creates a new profile" do
        expect {
          described_class.call(user: user, profile_params: profile_params)
        }.to change(Profile, :count).by(1)
      end

      it "generates a short_code" do
        result = described_class.call(user: user, profile_params: profile_params)
        
        expect(result[:profile].short_code).to be_present
        expect(result[:profile].short_code.length).to eq(8)
      end

      it "associates profile with user" do
        result = described_class.call(user: user, profile_params: profile_params)
        
        expect(result[:profile].user).to eq(user)
        expect(result[:profile].user_id).to eq(user.id)
      end

      it "enqueues ScrapeAndUpdateJob" do
        expect(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).once.with(kind_of(Integer))
        described_class.call(user: user, profile_params: profile_params)
      end

      it "returns success result with profile" do
        result = described_class.call(user: user, profile_params: profile_params)
        
        expect(result[:success]).to be true
        expect(result[:profile]).to be_a(Profile)
        expect(result[:scrape_success]).to be true
        expect(result[:scrape_message]).to eq("Extração de dados do Github enfileirada.")
      end

      it "saves profile attributes" do
        result = described_class.call(user: user, profile_params: profile_params)
        
        expect(result[:profile].name).to eq("Test User")
        expect(result[:profile].github_url).to eq("https://github.com/testuser")
      end
    end

    context "when enqueuing succeeds" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_return("jid-123")
      end

      it "still creates the profile" do
        expect {
          described_class.call(user: user, profile_params: profile_params)
        }.to change(Profile, :count).by(1)
      end

      it "returns scrape_success as true" do
        result = described_class.call(user: user, profile_params: profile_params)
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

      it "does not create a profile" do
        expect {
          described_class.call(user: user, profile_params: invalid_params)
        }.not_to change(Profile, :count)
      end

      it "returns failure result with errors" do
        result = described_class.call(user: user, profile_params: invalid_params)
        
        expect(result[:success]).to be false
        expect(result[:profile]).to be_a(Profile)
        expect(result[:profile].errors).to be_present
        expect(result[:errors]).to be_present
      end

      it "does not enqueue ScrapeAndUpdateJob" do
        expect(Profiles::ScrapeAndUpdateJob).not_to receive(:perform_async)
        described_class.call(user: user, profile_params: invalid_params)
      end
    end

    context "when an exception occurs" do
      before do
        allow_any_instance_of(Profile).to receive(:save).and_raise(StandardError.new("Database error"))
        allow(Rails.logger).to receive(:error)
      end

      it "returns failure result" do
        result = described_class.call(user: user, profile_params: profile_params)
        
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Database error")
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/\[Profiles::Create\] Error: Database error/)
        expect(Rails.logger).to receive(:error).with(anything)
        described_class.call(user: user, profile_params: profile_params)
      end

      it "does not create a profile" do
        expect {
          described_class.call(user: user, profile_params: profile_params)
        }.not_to change(Profile, :count)
      end
    end

    context "when enqueuing raises an exception" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_raise(StandardError.new("Queue error"))
        allow(Rails.logger).to receive(:error)
      end

      it "keeps created profile and returns failure payload" do
        expect {
          @result = described_class.call(user: user, profile_params: profile_params)
        }.to change(Profile, :count).by(1)
        expect(@result[:success]).to be false
        expect(@result[:error]).to eq("Queue error")
      end
    end
  end
end
