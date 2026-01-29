# frozen_string_literal: true

module Profiles
  class Create
    class Error < StandardError; end

    def self.call(user:, profile_params:)
      new(user: user, profile_params: profile_params).call
    end

    def initialize(user:, profile_params:)
      @user = user
      @profile_params = profile_params
    end

    def call
      ActiveRecord::Base.transaction do
        profile = build_profile
        Shortener::EncodeUrl.call(profile)
        
        unless profile.save
          return { success: false, profile: profile, errors: profile.errors }
        end

        scrape_result = Profiles::ScrapeAndUpdate.call(profile)
        
        {
          success: true,
          profile: profile,
          scrape_success: scrape_result[:success],
          scrape_message: scrape_result[:message]
        }
      end
    rescue StandardError => e
      Rails.logger.error("[Profiles::Create] Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, error: e.message }
    end

    private

    attr_reader :user, :profile_params

    def build_profile
      user.profiles.build(profile_params)
    end
  end
end
