require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:profiles).dependent(:destroy) }
  end

  describe "devise modules" do
    it "is database authenticatable" do
      user = create(:user)
      expect(user.valid_password?("123456")).to be true
    end

    it "is registerable" do
      expect(User.devise_modules).to include(:registerable)
    end

    it "is recoverable" do
      expect(User.devise_modules).to include(:recoverable)
    end

    it "is rememberable" do
      expect(User.devise_modules).to include(:rememberable)
    end

    it "is validatable" do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe "dependent destroy" do
    let(:user) { create(:user) }
    let!(:profile1) { create(:profile, user: user) }
    let!(:profile2) { create(:profile, user: user) }

    it "destroys associated profiles when user is destroyed" do
      expect { user.destroy }.to change(Profile, :count).by(-2)
    end
  end
end
