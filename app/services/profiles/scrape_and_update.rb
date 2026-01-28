# frozen_string_literal: true

module Profiles
  class ScrapeAndUpdate
    class Error < StandardError; end

    def self.call(profile)
      data = Github::ProfileScraper.call(profile.github_url)
      update_profile(profile, data)
      { success: true, message: nil }
    rescue Github::ProfileScraper::Error => e
      handle_scraper_error(profile, e)
      { success: false, message: e.message }
    end

    private

    def self.update_profile(profile, data)
      profile.update!(
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

    def self.handle_scraper_error(profile, error)
      Rails.logger.error("[Profiles::ScrapeAndUpdate] Scraper error for #{profile.github_url}: #{error.message}")
    end
  end
end
