# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::PaginationParams, type: :controller do
  controller(Api::BaseController) do
    include Api::PaginationParams

    def index
      render json: pagination_params
    end
  end

  let(:user) { create(:user) }
  let(:api_token) { user.api_token }
  let(:headers) { { "Authorization" => "Bearer #{api_token}" } }

  before do
    routes.draw do
      namespace :api do
        get 'test', to: 'base#index'
      end
    end
  end

  describe "#pagination_params" do
    context "with page and per_page parameters" do
      it "returns both parameters" do
        request.headers.merge!(headers)
        get :index, params: { page: 2, per_page: 20 }
        
        json = JSON.parse(response.body)
        expect(json["page"]).to eq("2")
        expect(json["per_page"]).to eq("20")
      end
    end

    context "with only page parameter" do
      it "returns page and nil per_page" do
        request.headers.merge!(headers)
        get :index, params: { page: 3 }
        
        json = JSON.parse(response.body)
        expect(json["page"]).to eq("3")
        expect(json["per_page"]).to be_nil
      end
    end

    context "with only per_page parameter" do
      it "returns nil page and per_page" do
        request.headers.merge!(headers)
        get :index, params: { per_page: 15 }
        
        json = JSON.parse(response.body)
        expect(json["page"]).to be_nil
        expect(json["per_page"]).to eq("15")
      end
    end

    context "without parameters" do
      it "returns nil for both" do
        request.headers.merge!(headers)
        get :index
        
        json = JSON.parse(response.body)
        expect(json["page"]).to be_nil
        expect(json["per_page"]).to be_nil
      end
    end

    context "with string parameters" do
      it "returns string values" do
        request.headers.merge!(headers)
        get :index, params: { page: "5", per_page: "25" }
        
        json = JSON.parse(response.body)
        expect(json["page"]).to eq("5")
        expect(json["per_page"]).to eq("25")
      end
    end
  end
end

