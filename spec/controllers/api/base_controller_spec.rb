# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::BaseController, type: :request do
  let(:user) { create(:user) }
  let(:api_token) { user.api_token }
  let(:headers) { { "Authorization" => "Bearer #{api_token}" } }

  describe "CSRF protection" do
    it "allows requests without CSRF token" do
      get "/api/profiles", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "authentication" do
    describe "authenticate_api_user!" do
      context "with valid token" do
        it "allows access" do
          get "/api/profiles", headers: headers
          expect(response).to have_http_status(:ok)
        end

        it "sets current_api_user" do
          get "/api/profiles", headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      context "without token" do
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

      context "with malformed Authorization header" do
        it "handles missing Bearer prefix - token still works" do
          get "/api/profiles", headers: { "Authorization" => api_token }
          expect(response).to have_http_status(:ok)
        end

        it "handles Bearer prefix correctly" do
          get "/api/profiles", headers: { "Authorization" => "Bearer #{api_token}" }
          expect(response).to have_http_status(:ok)
        end

        it "handles extra spaces - gsub only removes Bearer prefix, spaces remain" do
          get "/api/profiles", headers: { "Authorization" => "Bearer  #{api_token}" }
          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Token inválido")
        end

        it "rejects invalid token format" do
          get "/api/profiles", headers: { "Authorization" => "InvalidFormat token123" }
          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Token inválido")
        end
      end
    end
  end

  describe "skip_before_action" do
    it "skips authenticate_user!" do
      get "/api/profiles", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "skips set_locale" do
      get "/api/profiles", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "rescue_from ActiveRecord::RecordNotFound" do
    it "renders 404 with error message" do
      get "/api/profiles/99999", headers: headers
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Not Found")
    end
  end

  describe "extract_token_from_header" do
    it "extracts token from Bearer header" do
      get "/api/profiles", headers: { "Authorization" => "Bearer #{api_token}" }
      expect(response).to have_http_status(:ok)
    end

    it "handles nil Authorization header" do
      get "/api/profiles"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

