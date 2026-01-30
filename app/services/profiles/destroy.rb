# frozen_string_literal: true

module Profiles
  class Destroy
    def self.call(profile:, repository: ProfileRepository.new)
      new(profile: profile, repository: repository).call
    end

    def initialize(profile:, repository:)
      @profile = profile
      @repository = repository
    end

    def call
      profile_name = @profile.name
      repository.destroy(@profile)
      
      { success: true, profile_name: profile_name }
    rescue StandardError => e
      Rails.logger.error("[Profiles::Destroy] Error: #{e.message}")
      { success: false, error: e.message }
    end

    private

    attr_reader :repository
  end
end
