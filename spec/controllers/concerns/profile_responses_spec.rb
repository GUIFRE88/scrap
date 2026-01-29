# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfileResponses, type: :controller do
  controller(ProfilesController) do
  end

  let(:user) { create(:user) }
  let(:profile) { create(:profile, user: user) }

  before do
    sign_in user
    routes.draw do
      resources :profiles, only: [:new, :create, :edit, :update]
      get 'dashboard', to: 'home#dashboard'
    end
  end

  describe "#handle_create_success" do
    context "when scraping succeeds" do
      let(:result) do
        {
          success: true,
          profile: profile,
          scrape_success: true
        }
      end

      it "redirects with success notice" do
        allow(controller).to receive(:handle_create_success).and_call_original
        controller.instance_variable_set(:@profile, profile)
        
        expect(controller).to receive(:redirect_to).with(profile, notice: "Perfil criado com sucesso.")
        controller.send(:handle_create_success, result)
      end
    end

    context "when scraping fails" do
      let(:result) do
        {
          success: true,
          profile: profile,
          scrape_success: false
        }
      end

      it "redirects with alert message" do
        allow(controller).to receive(:handle_create_success).and_call_original
        controller.instance_variable_set(:@profile, profile)
        
        expect(controller).to receive(:redirect_to).with(profile)
        controller.send(:handle_create_success, result)
        
        expect(flash[:alert]).to eq("Perfil criado, mas houve erro ao extrair os dados do Github.")
      end
    end
  end

  describe "#handle_create_failure" do
    before do
      allow(Profiles::Create).to receive(:call).and_return({
        success: false,
        profile: build(:profile, name: "", user: user)
      })
    end

    it "sets @profile and renders new template" do
      post :create, params: { profile: { name: "", github_url: "https://github.com/test" } }
      
      expect(controller.instance_variable_get(:@profile)).to be_present
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
    end

    it "sets flash alert" do
      post :create, params: { profile: { name: "", github_url: "https://github.com/test" } }
      
      expect(flash.now[:alert]).to eq("Não foi possível criar o perfil.")
    end

    context "when profile is nil in result" do
      before do
        allow(Profiles::Create).to receive(:call).and_return({
          success: false,
          profile: nil
        })
      end

      it "builds a new profile from current_user" do
        post :create, params: { profile: { name: "", github_url: "https://github.com/test" } }
        
        expect(controller.instance_variable_get(:@profile)).to be_a(Profile)
        expect(controller.instance_variable_get(:@profile).user).to eq(user)
      end
    end
  end

  describe "#handle_update_success" do
    context "when scraping succeeds" do
      let(:result) do
        {
          success: true,
          profile: profile,
          scrape_success: true
        }
      end

      it "redirects with success notice" do
        controller.instance_variable_set(:@profile, profile)
        
        expect(controller).to receive(:redirect_to).with(profile, notice: "Perfil atualizado com sucesso.")
        controller.send(:handle_update_success, result)
      end
    end

    context "when scraping fails" do
      let(:result) do
        {
          success: true,
          profile: profile,
          scrape_success: false
        }
      end

      it "redirects with alert message" do
        controller.instance_variable_set(:@profile, profile)
        
        expect(controller).to receive(:redirect_to).with(profile)
        controller.send(:handle_update_success, result)
        
        expect(flash[:alert]).to eq("Perfil atualizado, mas houve erro ao extrair os dados do Github.")
      end
    end
  end

  describe "#handle_update_failure" do
    before do
      allow(Profiles::Update).to receive(:call).and_return({
        success: false,
        profile: profile
      })
    end

    it "renders edit template" do
      patch :update, params: { id: profile.id, profile: { name: "" } }
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:edit)
    end

    it "sets flash alert" do
      patch :update, params: { id: profile.id, profile: { name: "" } }
      
      expect(flash.now[:alert]).to eq("Não foi possível atualizar o perfil.")
    end
  end
end
