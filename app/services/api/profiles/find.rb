# frozen_string_literal: true

module Api
  module Profiles
    class Find
    def self.call(id:, repository: ProfileRepository.new)
      new(id: id, repository: repository).call
    end

    def initialize(id:, repository:)
      @id = id
      @repository = repository
    end

    def call
      {
        profile: profile,
        meta: build_meta
      }
    end

    private

    attr_reader :id, :repository

    def profile
      @profile ||= repository.find(id)
    end

      def build_meta
        {
          current_page: 1,
          per_page: 1,
          total_pages: 1,
          total_count: 1
        }
      end
    end
  end
end
