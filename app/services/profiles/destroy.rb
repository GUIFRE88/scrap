# frozen_string_literal: true

module Profiles
  class Destroy
    def self.call(profile:)
      new(profile: profile).call
    end

    def initialize(profile:)
      @profile = profile
    end

    def call
      profile_name = @profile.name
      @profile.destroy
      
      { success: true, profile_name: profile_name }
    rescue StandardError => e
      Rails.logger.error("[Profiles::Destroy] Error: #{e.message}")
      { success: false, error: e.message }
    end
  end
end
