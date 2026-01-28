class Profile < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :name, presence: true
  validates :github_url, presence: true, format: { with: %r{\Ahttps?://(www\.)?github\.com/}i }
  validates :short_code, uniqueness: true, allow_nil: true

  # Scopes
  scope :search, lambda { |query|
    return all if query.blank?

    q = "%#{query.downcase}%"
    where(
      "LOWER(name) LIKE :q OR LOWER(github_username) LIKE :q OR LOWER(organization) LIKE :q OR LOWER(location) LIKE :q",
      q: q
    )
  }
end

