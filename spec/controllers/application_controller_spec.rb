require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  # Testa através do HomeController que herda de ApplicationController
  controller(HomeController) do
  end

  routes { Rails.application.routes }

  describe "authentication" do
    it "requires authentication" do
      get :dashboard
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "locale" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "sets locale to Portuguese" do
      get :dashboard
      expect(I18n.locale).to eq(:pt)
    end
  end
end
