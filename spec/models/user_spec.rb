# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:profiles).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password).on(:create) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
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

  describe "callbacks" do
    describe "before_create :generate_api_token" do
      it "generates api_token automatically on creation" do
        user = build(:user)
        expect(user.api_token).to be_nil
        
        user.save!
        expect(user.api_token).to be_present
        expect(user.api_token.length).to eq(64) # 32 bytes hex = 64 chars
      end

      it "generates unique api_tokens" do
        user1 = create(:user)
        user2 = create(:user)
        
        expect(user1.api_token).not_to eq(user2.api_token)
      end

      it "generates different token if collision occurs" do
        user1 = create(:user)
        original_token = user1.api_token
        
        user2 = build(:user)
        allow(SecureRandom).to receive(:hex).and_return(original_token, "different_token")
        
        user2.save!
        expect(user2.api_token).to eq("different_token")
      end
    end
  end

  describe "#generate_api_token" do
    let(:user) { build(:user) }

    it "generates a 64-character hex token" do
      user.generate_api_token
      expect(user.api_token).to be_present
      expect(user.api_token.length).to eq(64)
      expect(user.api_token).to match(/\A[0-9a-f]{64}\z/)
    end

    it "generates different tokens on each call" do
      user.generate_api_token
      first_token = user.api_token
      
      user.generate_api_token
      second_token = user.api_token
      
      expect(first_token).not_to eq(second_token)
    end

    it "handles token collisions by regenerating" do
      existing_user = create(:user)
      existing_token = existing_user.api_token
      
      # Simular colisão
      allow(SecureRandom).to receive(:hex).and_return(existing_token, "new_unique_token")
      
      user.generate_api_token
      expect(user.api_token).to eq("new_unique_token")
    end
  end

  describe "#regenerate_api_token!" do
    let(:user) { create(:user) }

    it "generates a new api_token" do
      original_token = user.api_token
      user.regenerate_api_token!
      
      expect(user.api_token).not_to eq(original_token)
      expect(user.api_token).to be_present
    end

    it "saves the user with new token" do
      user.regenerate_api_token!
      user.reload
      
      expect(user.api_token).to be_present
      expect(user.api_token.length).to eq(64)
    end

    it "persists the change to database" do
      original_token = user.api_token
      user.regenerate_api_token!
      
      reloaded_user = User.find(user.id)
      expect(reloaded_user.api_token).not_to eq(original_token)
      expect(reloaded_user.api_token).to eq(user.api_token)
    end

    context "when save fails" do
      before do
        allow(user).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(user))
      end

      it "raises an error" do
        expect {
          user.regenerate_api_token!
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "api_token uniqueness" do
    it "generates api_token automatically, so nil is not possible" do
      user = create(:user)
      expect(user.api_token).to be_present
      expect(user.api_token.length).to eq(64)
    end

    it "ensures unique api_tokens are generated" do
      user1 = create(:user)
      user2 = create(:user)
      
      expect(user1.api_token).not_to eq(user2.api_token)
      expect(user1.api_token).to be_present
      expect(user2.api_token).to be_present
    end
  end

  describe "dependent destroy" do
    let(:user) { create(:user) }
    let!(:profile1) { create(:profile, user: user) }
    let!(:profile2) { create(:profile, user: user) }

    it "destroys associated profiles when user is destroyed" do
      expect { user.destroy }.to change(Profile, :count).by(-2)
    end

    it "does not destroy profiles from other users" do
      other_user = create(:user)
      other_profile = create(:profile, user: other_user)
      
      user.destroy
      
      expect(Profile.find_by(id: other_profile.id)).to be_present
    end
  end

  describe "email validation" do
    it "rejects invalid email formats" do
      user = build(:user, email: "invalid-email")
      expect(user).not_to be_valid
    end

    it "accepts valid email formats" do
      user = build(:user, email: "valid@example.com")
      expect(user).to be_valid
    end

    it "is case insensitive for uniqueness" do
      base_email = "test#{SecureRandom.hex(4)}@example.com"
      create(:user, email: base_email.upcase)
      duplicate = build(:user, email: base_email.downcase)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end
  end

  describe "password validation" do
    it "requires password on create" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it "requires minimum password length" do
      user = build(:user, password: "12345")
      expect(user).not_to be_valid
    end

    it "accepts password with minimum length" do
      user = build(:user, password: "123456")
      expect(user).to be_valid
    end
  end
end
