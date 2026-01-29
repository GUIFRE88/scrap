require "rails_helper"

RSpec.describe Shortener::EncodeUrl do
  let(:profile) { build(:profile, short_code: nil) }

  describe ".call" do
    it "generates a unique short code" do
      described_class.call(profile)
      expect(profile.short_code).to be_present
      expect(profile.short_code.length).to eq(8)
    end

    it "does not regenerate if short_code already exists" do
      profile.short_code = "existing"
      described_class.call(profile)
      expect(profile.short_code).to eq("existing")
    end

    it "generates unique codes" do
      codes = []
      10.times do
        new_profile = build(:profile, short_code: nil)
        described_class.call(new_profile)
        codes << new_profile.short_code
      end

      expect(codes.uniq.length).to eq(10)
    end

    context "when code already exists" do
      before do
        create(:profile, short_code: "abc12345")
      end

      it "generates a different code" do
        allow_any_instance_of(Shortener::EncodeUrl).to receive(:random_code).and_return(
          "abc12345",
          "xyz98765"
        )

        described_class.call(profile)
        expect(profile.short_code).to eq("xyz98765")
      end
    end
  end

  describe "#random_code" do
    it "generates code with correct length" do
      service = Shortener::EncodeUrl.new(profile, repository: ProfileRepository.new)
      code = service.send(:random_code)
      expect(code.length).to eq(8)
    end

    it "uses only allowed characters" do
      service = Shortener::EncodeUrl.new(profile, repository: ProfileRepository.new)
      code = service.send(:random_code)
      expect(code).to match(/\A[a-zA-Z0-9]{8}\z/)
    end
  end
end
