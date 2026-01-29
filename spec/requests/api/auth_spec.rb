# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::AuthController", type: :request do
  describe "POST /api/auth/login" do
    let(:user) { create(:user, email: "test#{SecureRandom.hex(4)}@example.com", password: "password123") }

    context "with valid credentials" do
      it "returns the api token and user data" do
        post "/api/auth/login", params: {
          email: user.email,
          password: "password123"
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json["token"]).to be_present
        expect(json["token"]).to eq(user.reload.api_token)
        expect(json["user"]["id"]).to eq(user.id)
        expect(json["user"]["email"]).to eq(user.email)
      end

      it "generates api_token if blank" do
        user.update_column(:api_token, nil)
        
        post "/api/auth/login", params: {
          email: user.email,
          password: "password123"
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["token"]).to be_present
        expect(user.reload.api_token).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized with wrong password" do
        post "/api/auth/login", params: {
          email: "test@example.com",
          password: "wrong_password"
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Credenciais inválidas")
      end

      it "returns unauthorized with non-existent email" do
        post "/api/auth/login", params: {
          email: "nonexistent@example.com",
          password: "password123"
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Credenciais inválidas")
      end
    end

    context "with missing parameters" do
      it "returns bad_request when email is missing" do
        post "/api/auth/login", params: {
          password: "password123"
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Email e senha são obrigatórios")
      end

      it "returns bad_request when password is missing" do
        post "/api/auth/login", params: {
          email: "test@example.com"
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Email e senha são obrigatórios")
      end

      it "returns bad_request when both are missing" do
        post "/api/auth/login", params: {}, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Email e senha são obrigatórios")
      end

      it "returns bad_request when email is blank" do
        post "/api/auth/login", params: {
          email: "",
          password: "password123"
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Email e senha são obrigatórios")
      end

      it "returns bad_request when password is blank" do
        post "/api/auth/login", params: {
          email: "test@example.com",
          password: ""
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Email e senha são obrigatórios")
      end
    end

    context "authentication bypass" do
      it "does not require api token authentication" do
        post "/api/auth/login", params: {
          email: "test@example.com",
          password: "password123"
        }, as: :json

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
