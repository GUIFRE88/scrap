# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Rescan do
  let(:profile) { create(:profile) }

  describe ".call" do
    context "when scraping succeeds" do
      before do
        allow(Profiles::ScrapeAndUpdate).to receive(:call).and_return(
          { success: true, message: nil }
        )
      end

      it "calls ScrapeAndUpdate service" do
        expect(Profiles::ScrapeAndUpdate).to receive(:call).once.with(profile)
        described_class.call(profile: profile)
      end

      it "returns success result with default message" do
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq("Perfil re-escaneado com sucesso.")
      end

      it "returns success result with custom message" do
        allow(Profiles::ScrapeAndUpdate).to receive(:call).and_return(
          { success: true, message: "Custom success message" }
        )
        
        result = described_class.call(profile: profile)
        expect(result[:message]).to eq("Custom success message")
      end
    end

    context "when scraping fails" do
      before do
        allow(Profiles::ScrapeAndUpdate).to receive(:call).and_return(
          { success: false, message: "Scraping failed" }
        )
      end

      it "returns failure result with message from ScrapeAndUpdate" do
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be false
        expect(result[:message]).to eq("Scraping failed")
      end

      it "returns failure result with default message when message is nil" do
        allow(Profiles::ScrapeAndUpdate).to receive(:call).and_return(
          { success: false, message: nil }
        )
        
        result = described_class.call(profile: profile)
        expect(result[:success]).to be false
        expect(result[:message]).to eq("Erro ao re-escanear perfil.")
      end
    end

    context "when an exception occurs" do
      before do
        allow(Profiles::ScrapeAndUpdate).to receive(:call).and_raise(StandardError.new("Unexpected error"))
        allow(Rails.logger).to receive(:error)
      end

      it "returns failure result" do
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
