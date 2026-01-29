# frozen_string_literal: true

module Profiles
  class Update
    class Error < StandardError; end

    def self.call(profile:, profile_params:)
      new(profile: profile, profile_params: profile_params).call
    end

    def initialize(profile:, profile_params:)
      @profile = profile
      @profile_params = profile_params
    end

    def call
      ActiveRecord::Base.transaction do
        unless @profile.update(profile_params)
          return { success: false, profile: @profile, errors: @profile.errors }
        end

        scrape_result = Profiles::ScrapeAndUpdate.call(@profile)
        
        {
          success: true,
          profile: @profile,
          scrape_success: scrape_result[:success],
          scrape_message: scrape_result[:message]
        }
      end
    rescue StandardError => e
      Rails.logger.error("[Profiles::Update] Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, error: e.message }
    end

    private

    attr_reader :profile_params
  end
end
