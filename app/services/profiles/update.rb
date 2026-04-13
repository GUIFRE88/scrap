# frozen_string_literal: true

module Profiles
  class Update
    class Error < StandardError; end

    def self.call(profile:, profile_params:, repository: ProfileRepository.new)
      new(profile: profile, profile_params: profile_params, repository: repository).call
    end

    def initialize(profile:, profile_params:, repository:)
      @profile = profile
      @profile_params = profile_params
      @repository = repository
    end

    def call
      result = ActiveRecord::Base.transaction do
        unless repository.update(@profile, profile_params)
          return { success: false, profile: @profile, errors: @profile.errors }
        end

        {
          success: true,
          profile: @profile
        }
      end

      Profiles::ScrapeAndUpdateJob.perform_async(@profile.id)
      result.merge(scrape_success: true, scrape_message: "Extração de dados do Github enfileirada.")
    rescue StandardError => e
      Rails.logger.error("[Profiles::Update] Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, error: e.message }
    end

    private

    attr_reader :profile_params, :repository
  end
end
