class GenerateApiTokensForExistingUsers < ActiveRecord::Migration[7.0]
  def up
    User.where(api_token: nil).find_each do |user|
      loop do
        token = SecureRandom.hex(32)
        unless User.exists?(api_token: token)
          user.update_column(:api_token, token)
          break
        end
      end
    end
  end
end
