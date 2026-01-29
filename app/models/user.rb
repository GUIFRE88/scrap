class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :profiles, dependent: :destroy

  before_create :generate_api_token

  def generate_api_token
    loop do
      self.api_token = SecureRandom.hex(32)
      break unless User.exists?(api_token: api_token)
    end
  end

  def regenerate_api_token!
    generate_api_token
    save!
  end
end
