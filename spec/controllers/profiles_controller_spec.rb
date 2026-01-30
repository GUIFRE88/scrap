require "rails_helper"

RSpec.describe ProfilesController, type: :controller do
  routes { Rails.application.routes }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:profile) { create(:profile, user: user) }

  before do
    sign_in user
  end

  describe "GET #index" do
    let!(:profile1) { create(:profile, user: user, name: "Profile 1") }
    let!(:profile2) { create(:profile, user: user, name: "Profile 2") }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns user profiles" do
      get :index
      expect(assigns(:profiles)).to include(profile1, profile2)
    end

    context "with search query" do
      it "filters profiles" do
        get :index, params: { q: "Profile 1" }
        expect(assigns(:profiles)).to include(profile1)
        expect(assigns(:profiles)).not_to include(profile2)
      end
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: profile.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the profile" do
      get :show, params: { id: profile.id }
      expect(assigns(:profile)).to eq(profile)
    end

    context "when profile belongs to another user" do
      let(:other_profile) { create(:profile, user: other_user) }

      it "raises RecordNotFound" do
        expect {
          get :show, params: { id: other_profile.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "assigns a new profile" do
      get :new
      expect(assigns(:profile)).to be_a_new(Profile)
      expect(assigns(:profile).user).to eq(user)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        name: "New Profile",
        github_url: "https://github.com/newuser"
      }
    end

    context "with valid params" do
      before do
        allow(Profiles::Create).to receive(:call).and_return({
          success: true,
          profile: profile,
          scrape_success: true
        })
      end

      it "calls Profiles::Create service" do
        expect(Profiles::Create).to receive(:call).with(
          user: user,
          profile_params: ActionController::Parameters.new(valid_attributes).permit!
        )
        post :create, params: { profile: valid_attributes }
      end

      it "redirects to the profile with notice" do
        post :create, params: { profile: valid_attributes }
        expect(response).to redirect_to(profile)
        expect(flash[:notice]).to eq("Perfil criado com sucesso.")
      end

      context "when scraping fails" do
        before do
          allow(Profiles::Create).to receive(:call).and_return({
            success: true,
            profile: profile,
            scrape_success: false
          })
        end

        it "redirects but with alert" do
          post :create, params: { profile: valid_attributes }
          expect(response).to redirect_to(profile)
          expect(flash[:alert]).to eq("Perfil criado, mas houve erro ao extrair os dados do Github.")
        end
      end
    end

    context "with invalid params" do
      before do
        invalid_profile = build(:profile, name: "", user: user)
        allow(Profiles::Create).to receive(:call).and_return({
          success: false,
          profile: invalid_profile,
          errors: invalid_profile.errors
        })
      end

      it "does not create a profile" do
        expect {
          post :create, params: { profile: { name: "" } }
        }.not_to change(Profile, :count)
      end

      it "renders new template" do
        post :create, params: { profile: { name: "" } }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets flash alert" do
        post :create, params: { profile: { name: "" } }
        expect(flash.now[:alert]).to eq("Não foi possível criar o perfil.")
      end
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: profile.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the profile" do
      get :edit, params: { id: profile.id }
      expect(assigns(:profile)).to eq(profile)
    end
  end

  describe "PATCH #update" do
    let(:update_attributes) do
      {
        name: "Updated Name",
        github_url: "https://github.com/updated"
      }
    end

    context "with valid params" do
      before do
        allow(Profiles::Update).to receive(:call).and_return({
          success: true,
          profile: profile,
          scrape_success: true
        })
      end

      it "calls Profiles::Update service" do
        expect(Profiles::Update).to receive(:call).with(
          profile: profile,
          profile_params: ActionController::Parameters.new(update_attributes).permit!
        )
        patch :update, params: { id: profile.id, profile: update_attributes }
      end

      it "redirects to the profile with notice" do
        patch :update, params: { id: profile.id, profile: update_attributes }
        expect(response).to redirect_to(profile)
        expect(flash[:notice]).to eq("Perfil atualizado com sucesso.")
      end

      context "when scraping fails" do
        before do
          allow(Profiles::Update).to receive(:call).and_return({
            success: true,
            profile: profile,
            scrape_success: false
          })
        end

        it "redirects but with alert" do
          patch :update, params: { id: profile.id, profile: update_attributes }
          expect(response).to redirect_to(profile)
          expect(flash[:alert]).to eq("Perfil atualizado, mas houve erro ao extrair os dados do Github.")
        end
      end
    end

    context "with invalid params" do
      before do
        allow(Profiles::Update).to receive(:call).and_return({
          success: false,
          profile: profile,
          errors: profile.errors
        })
      end

      it "renders edit template" do
        patch :update, params: { id: profile.id, profile: { name: "" } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets flash alert" do
        patch :update, params: { id: profile.id, profile: { name: "" } }
        expect(flash.now[:alert]).to eq("Não foi possível atualizar o perfil.")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:profile_to_destroy) { create(:profile, user: user) }

    before do
      allow(Profiles::Destroy).to receive(:call).and_return({
        success: true,
        message: "Perfil removido com sucesso."
      })
    end

    it "calls Profiles::Destroy service" do
      expect(Profiles::Destroy).to receive(:call).with(profile: profile_to_destroy)
      delete :destroy, params: { id: profile_to_destroy.id }
    end

    it "redirects to dashboard with notice" do
      delete :destroy, params: { id: profile_to_destroy.id }
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:notice]).to eq("Perfil removido com sucesso.")
    end

    context "when destruction fails" do
      before do
        allow(Profiles::Destroy).to receive(:call).and_return({
          success: false,
          message: "Erro ao remover perfil: Database error"
        })
      end

      it "redirects with alert" do
        delete :destroy, params: { id: profile_to_destroy.id }
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:alert]).to eq("Erro ao remover perfil: Database error")
      end
    end
  end

  describe "POST #rescan" do
    before do
      allow(Profiles::Rescan).to receive(:call).and_return({
        success: true,
        message: "Perfil re-escaneado com sucesso."
      })
    end

    it "calls Profiles::Rescan service" do
      expect(Profiles::Rescan).to receive(:call).with(profile: profile)
      post :rescan, params: { id: profile.id }
    end

    it "redirects to profile with notice" do
      post :rescan, params: { id: profile.id }
      expect(response).to redirect_to(profile)
      expect(flash[:notice]).to eq("Perfil re-escaneado com sucesso.")
    end

    context "when rescan fails" do
      before do
        allow(Profiles::Rescan).to receive(:call).and_return({
          success: false,
          message: "Erro ao re-escanear perfil."
        })
      end

      it "redirects with alert" do
        post :rescan, params: { id: profile.id }
        expect(response).to redirect_to(profile)
        expect(flash[:alert]).to eq("Erro ao re-escanear perfil.")
      end
    end
  end

  describe "GET #redirect" do
    let(:profile_with_code) { create(:profile, short_code: "abc123", github_url: "https://github.com/user") }

    it "redirects to GitHub URL" do
      get :redirect, params: { short_code: profile_with_code.short_code }
      expect(response).to redirect_to(profile_with_code.github_url)
    end

    it "raises error when profile not found" do
      expect {
        get :redirect, params: { short_code: "nonexistent" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
