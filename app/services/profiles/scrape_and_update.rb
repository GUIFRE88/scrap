# frozen_string_literal: true

module Profiles
  class ScrapeAndUpdate
    class Error < StandardError; end

    def self.call(profile, repository: ProfileRepository.new)
      new(profile: profile, repository: repository).call
    end

    def initialize(profile:, repository:)
      @profile = profile
      @repository = repository
    end

    def call
      data = Github::ProfileScraper.call(@profile.github_url)
      update_profile(data)
      { success: true, message: nil }
    rescue Github::ProfileScraper::Error => e
      handle_scraper_error(e)
      { success: false, message: e.message }
    end

    private

    attr_reader :profile, :repository

    def update_profile(data)
      repository.update!(
        @profile,
        github_username: data[:github_username],
        followers_count: data[:followers_count],
        following_count: data[:following_count],
        stars_count: data[:stars_count],
        contributions_last_year: data[:contributions_last_year],
        avatar_url: data[:avatar_url],
        organization: data[:organization],
        location: data[:location],
        last_scanned_at: Time.current
      )
    end

    def handle_scraper_error(error)
      Rails.logger.error("[Profiles::ScrapeAndUpdate] Scraper error for #{@profile.github_url}: #{error.message}")
    end

    def self.handle_scraper_error(profile, error)
      Rails.logger.error("[Profiles::ScrapeAndUpdate] Scraper error for #{profile.github_url}: #{error.message}")
    end
  end
end
