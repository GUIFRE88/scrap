require "rails_helper"

RSpec.describe "API Profiles", type: :request do
  let(:user) { create(:user) }
  let(:api_token) { user.api_token }
  let(:headers) { { "Authorization" => "Bearer #{api_token}" } }
  let!(:profiles) { create_list(:profile, 3, user: user) }

  describe "GET /api/profiles" do
    it "retorna lista paginada de perfis no formato esperado" do
      get "/api/profiles", params: { page: 1, per_page: 2 }, headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key("data")
      expect(json).to have_key("meta")

      expect(json["data"].size).to eq(2)

      first = json["data"].first
      expect(first).to include(
        "id",
        "name",
        "github_username",
        "short_github_url",
        "followers",
        "following",
        "stars",
        "contributions_last_year",
        "avatar_url",
        "location",
        "organizations"
      )

      expect(json["meta"]).to include(
        "current_page" => 1,
        "per_page"     => 2,
        "total_pages"  => 2,
        "total_count"  => 3
      )
    end
  end

  describe "GET /api/profiles/:id" do
    let(:profile) { profiles.first }

    it "retorna os detalhes de um perfil específico" do
      get "/api/profiles/#{profile.id}", headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key("data")
      expect(json).to have_key("meta")

      data = json["data"]
      expect(data["id"]).to eq(profile.id)
      expect(data["name"]).to eq(profile.name)
      expect(data["github_username"]).to eq(profile.github_username)
    end

    it "retorna 404 quando o perfil não existe" do
      get "/api/profiles/99999", headers: headers

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Not Found")
    end
  end
end

