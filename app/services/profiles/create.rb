# frozen_string_literal: true

module Profiles
  class Create
    class Error < StandardError; end

    def self.call(user:, profile_params:, repository: ProfileRepository.new)
      new(user: user, profile_params: profile_params, repository: repository).call
    end

    def initialize(user:, profile_params:, repository:)
      @user = user
      @profile_params = profile_params
      @repository = repository
    end

    def call
      result = ActiveRecord::Base.transaction do
        profile = build_profile
        Shortener::EncodeUrl.call(profile, repository: repository)

        unless repository.save(profile)
          return { success: false, profile: profile, errors: profile.errors }
        end

        {
          success: true,
          profile: profile
        }
      end

      Profiles::ScrapeAndUpdateJob.perform_async(result[:profile].id)
      result.merge(scrape_success: true, scrape_message: "Extração de dados do Github enfileirada.")
    rescue StandardError => e
      Rails.logger.error("[Profiles::Create] Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, error: e.message }
    end

    private

    attr_reader :user, :profile_params, :repository

    def build_profile
      repository.build(user, profile_params)
    end
  end
end
