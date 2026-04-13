# frozen_string_literal: true

module Profiles
  class ScrapeAndUpdateJob
    include Sidekiq::Job

    sidekiq_options queue: :scrape_and_update

    def perform(profile_id)
      profile = Profile.find_by(id: profile_id)
      return unless profile

      Profiles::ScrapeAndUpdate.call(profile)
    end
  end
end
