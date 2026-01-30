# frozen_string_literal: true

module Api
  module Profiles
    class Find
    def self.call(user:, id:, repository: ProfileRepository.new)
      new(user: user, id: id, repository: repository).call
    end

    def initialize(user:, id:, repository:)
      @user = user
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

    attr_reader :user, :id, :repository

    def profile
      @profile ||= repository.user_profiles(user).find(id)
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
