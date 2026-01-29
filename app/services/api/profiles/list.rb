# frozen_string_literal: true

module Api
  module Profiles
    class List
      DEFAULT_PAGE = 1
      DEFAULT_PER_PAGE = 10
      MAX_PER_PAGE = 100

    def self.call(page: nil, per_page: nil, repository: ProfileRepository.new)
      new(page: page, per_page: per_page, repository: repository).call
    end

    def initialize(page: nil, per_page: nil, repository:)
      @page = normalize_page(page)
      @per_page = normalize_per_page(per_page)
      @repository = repository
    end

    def call
      {
        profiles: paginated_profiles,
        meta: build_meta
      }
    end

    private

    attr_reader :page, :per_page, :repository

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

    def paginated_profiles
      repository.paginate(page: page, per_page: per_page)
    end

      def build_meta
        {
          current_page: paginated_profiles.current_page,
          per_page: per_page,
          total_pages: paginated_profiles.total_pages,
          total_count: paginated_profiles.total_entries
        }
      end
    end
  end
end
