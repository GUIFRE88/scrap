require "rails_helper"

RSpec.describe Users::SessionsController, type: :controller do
  routes { Rails.application.routes }

  describe "after_sign_in_path_for" do
    let(:user) { build(:user) }

    it "returns dashboard path" do
      expect(controller.send(:after_sign_in_path_for, user)).to eq(dashboard_path)
    end
  end
end
