require "rails_helper"

RSpec.describe Users::RegistrationsController, type: :controller do
  routes { Rails.application.routes }

  describe "after_sign_up_path_for" do
    let(:user) { build(:user) }

    it "returns dashboard path" do
      expect(controller.send(:after_sign_up_path_for, user)).to eq(dashboard_path)
    end
  end

  describe "after_inactive_sign_up_path_for" do
    let(:user) { build(:user) }

    it "returns new session path" do
      expect(controller.send(:after_inactive_sign_up_path_for, user)).to eq(new_user_session_path)
    end
  end
end
