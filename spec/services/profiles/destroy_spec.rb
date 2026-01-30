# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Destroy do
  describe ".call" do
    context "when destruction succeeds" do
      let(:profile) { create(:profile, name: "Test Profile") }

      it "deletes the profile" do
        profile_id = profile.id
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be true
        expect(Profile.find_by(id: profile_id)).to be_nil
      end

      it "returns success result with message" do
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq("Perfil removido com sucesso.")
      end

      it "removes profile from database" do
        profile_id = profile.id
        described_class.call(profile: profile)
        
        expect(Profile.find_by(id: profile_id)).to be_nil
      end
    end

    context "when an exception occurs" do
      let(:profile) { create(:profile, name: "Test Profile") }

      before do
        allow(profile).to receive(:destroy).and_raise(StandardError.new("Database error"))
        allow(Rails.logger).to receive(:error)
      end

      it "returns failure result" do
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be false
        expect(result[:message]).to eq("Erro ao remover perfil: Database error")
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/\[Profiles::Destroy\] Error: Database error/)
        described_class.call(profile: profile)
      end

      it "does not delete the profile" do
        profile_id = profile.id
        described_class.call(profile: profile)
        
        expect(Profile.find_by(id: profile_id)).to be_present
      end
    end

    context "when profile belongs to user" do
      let(:profile) { create(:profile, name: "Test Profile") }

      it "deletes the profile" do
        profile_id = profile.id
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be true
        expect(Profile.find_by(id: profile_id)).to be_nil
      end

      it "does not delete the user" do
        user = profile.user
        result = described_class.call(profile: profile)
        
        expect(result[:success]).to be true
        expect(user.reload).to be_present
      end
    end
  end
end
