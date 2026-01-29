# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::ProfilesController", type: :request do
  let(:user) { create(:user) }
  let(:api_token) { user.api_token }
  let(:headers) { { "Authorization" => "Bearer #{api_token}" } }

  describe "GET /api/profiles" do
    let!(:profile1) { create(:profile, user: user, created_at: 2.days.ago) }
    let!(:profile2) { create(:profile, user: user, created_at: 1.day.ago) }
    let!(:other_user_profile) { create(:profile) }

    context "with valid authentication" do
      it "returns paginated profiles" do
        get "/api/profiles", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json["data"]).to be_an(Array)
        expect(json["meta"]).to be_a(Hash)
        expect(json["meta"]["current_page"]).to eq(1)
        expect(json["meta"]["per_page"]).to eq(10)
      end

      it "returns all profiles regardless of user" do
        get "/api/profiles", headers: headers

        json = JSON.parse(response.body)
        profile_ids = json["data"].map { |p| p["id"] }
        
        expect(profile_ids).to include(profile1.id, profile2.id, other_user_profile.id)
      end

      it "respects pagination parameters" do
        create_list(:profile, 15)
        
        get "/api/profiles", params: { page: 2, per_page: 5 }, headers: headers

        json = JSON.parse(response.body)
        expect(json["data"].size).to eq(5)
        expect(json["meta"]["current_page"]).to eq(2)
        expect(json["meta"]["per_page"]).to eq(5)
      end

      it "uses default pagination when not provided" do
        get "/api/profiles", headers: headers

        json = JSON.parse(response.body)
        expect(json["meta"]["per_page"]).to eq(10)
        expect(json["meta"]["current_page"]).to eq(1)
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        get "/api/profiles"

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Token de autenticação não fornecido")
      end
    end

    context "with invalid token" do
      it "returns unauthorized" do
        get "/api/profiles", headers: { "Authorization" => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Token inválido")
      end
    end
  end

  describe "GET /api/profiles/:id" do
    let(:profile) { create(:profile, user: user) }

    context "with valid authentication" do
      it "returns the profile" do
        get "/api/profiles/#{profile.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json["data"]["id"]).to eq(profile.id)
        expect(json["data"]["name"]).to eq(profile.name)
        expect(json["meta"]).to be_a(Hash)
      end

      it "returns profile regardless of ownership" do
        other_profile = create(:profile)
        
        get "/api/profiles/#{other_profile.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"]["id"]).to eq(other_profile.id)
      end
    end

    context "when profile does not exist" do
      it "returns not found" do
        get "/api/profiles/99999", headers: headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not Found")
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        get "/api/profiles/#{profile.id}"

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Token de autenticação não fornecido")
      end
    end
  end
end
