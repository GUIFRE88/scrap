# frozen_string_literal: true

module Profiles
  class DashboardList
    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 10
    MAX_PER_PAGE = 50

    def self.call(user:, query: nil, page: nil, per_page: nil, repository: ProfileRepository.new)
      new(user: user, query: query, page: page, per_page: per_page, repository: repository).call
    end

    def initialize(user:, query: nil, page: nil, per_page: nil, repository:)
      @user = user
      @query = query
      @page = normalize_page(page)
      @per_page = normalize_per_page(per_page)
      @repository = repository
    end

    def call
      {
        profiles: paginated_profiles,
        query: normalized_query
      }
    end

    private

    attr_reader :user, :query, :page, :per_page, :repository

    def normalize_page(page)
      page_value = page.to_i
      page_value.positive? ? page_value : DEFAULT_PAGE
    end

    def normalize_per_page(per_page)
      per_page_value = per_page.to_i
      return DEFAULT_PER_PAGE if per_page_value <= 0
      return MAX_PER_PAGE if per_page_value > MAX_PER_PAGE

      per_page_value
    end

    def normalized_query
      query.to_s.strip.presence
    end

    def paginated_profiles
      base_scope
        .search(normalized_query)
        .order(created_at: :desc)
        .paginate(page: page, per_page: per_page)
    end

    def base_scope
      repository.user_profiles(user)
    end
  end
end
