require "rails_helper"

RSpec.describe Api::BaseController, type: :request do
  describe "CSRF protection" do
    it "allows requests without CSRF token" do
      get "/api/profiles"
      expect(response).to have_http_status(:success)
    end
  end

  describe "authentication" do
    it "does not require authentication" do
      get "/api/profiles"
      expect(response).to have_http_status(:success)
    end
  end

  describe "rescue_from ActiveRecord::RecordNotFound" do
    it "renders 404 with error message" do
      get "/api/profiles/999_999"
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Not Found")
    end
  end
end
