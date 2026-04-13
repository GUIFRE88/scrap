# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Rescan do
  let(:profile) { create(:profile) }

  describe ".call" do
    context "when enqueuing succeeds" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_return("jid-123")
      end

      it "enqueues ScrapeAndUpdateJob" do
        expect(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).once.with(profile.id)
        described_class.call(profile: profile)
      end

      it "returns success result with default message" do
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq("Re-escaneamento enfileirado com sucesso.")
      end
    end

    context "when enqueuing fails" do
      before do
        allow(Profiles::ScrapeAndUpdateJob).to receive(:perform_async).and_raise(StandardError.new("Unexpected error"))
        allow(Rails.logger).to receive(:error)
      end

      it "returns failure result with error message" do
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be false
        expect(result[:message]).to eq("Erro ao re-escanear perfil: Unexpected error")
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/\[Profiles::Rescan\] Error: Unexpected error/)
        described_class.call(profile: profile)
      end
    end
  end
end
