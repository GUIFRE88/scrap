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

    # Remove espaços em branco no início e fim da query
    cleaned_query = query.to_s.strip
    return all if cleaned_query.blank?

    q = "%#{cleaned_query.downcase}%"
    numeric_query = cleaned_query.to_i
    
    conditions = [
      "LOWER(name) LIKE :q",
      "LOWER(github_url) LIKE :q",
      "LOWER(github_username) LIKE :q",
      "LOWER(organization) LIKE :q",
      "LOWER(location) LIKE :q",
      "LOWER(short_code) LIKE :q"
    ]
    
    # Adiciona busca numérica se a query for um número
    if numeric_query > 0
      conditions << "followers_count = :nq"
      conditions << "following_count = :nq"
      conditions << "stars_count = :nq"
      conditions << "contributions_last_year = :nq"
      where(conditions.join(" OR "), q: q, nq: numeric_query)
    else
      where(conditions.join(" OR "), q: q)
    end
  }
end

