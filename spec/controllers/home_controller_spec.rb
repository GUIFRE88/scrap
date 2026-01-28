require "rails_helper"

RSpec.describe HomeController, type: :controller do
  routes { Rails.application.routes }

  let(:user) { create(:user) }
  let!(:profile1) { create(:profile, user: user, name: "Profile 1") }
  let!(:profile2) { create(:profile, user: user, name: "Profile 2") }
  let!(:other_profile) { create(:profile, name: "Other Profile") }

  before do
    sign_in user
  end

  describe "GET #dashboard" do
    it "returns http success" do
      get :dashboard
      expect(response).to have_http_status(:success)
    end

    it "assigns user profiles" do
      get :dashboard
      expect(assigns(:profiles)).to include(profile1, profile2)
      expect(assigns(:profiles)).not_to include(other_profile)
    end

    it "orders profiles by created_at desc" do
      get :dashboard
      profiles = assigns(:profiles)
      expect(profiles.first).to eq(profile2)
      expect(profiles.last).to eq(profile1)
    end

    context "with search query" do
      it "filters profiles by query" do
        get :dashboard, params: { q: "Profile 1" }
        expect(assigns(:profiles)).to include(profile1)
        expect(assigns(:profiles)).not_to include(profile2)
      end
    end

    context "with pagination" do
      before do
        Profile.where(user: user).destroy_all
        create_list(:profile, 15, user: user)
      end

      it "paginates results" do
        get :dashboard, params: { page: 1 }
        profiles = assigns(:profiles)
        expect(profiles.size).to eq(10)
        expect(profiles.total_pages).to eq(2)
        expect(profiles.total_entries).to eq(15)
      end
    end
  end
end
