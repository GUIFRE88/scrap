# frozen_string_literal: true

module Profiles
  class ScrapeAndUpdateJob
    include Sidekiq::Job
    include ActionView::RecordIdentifier

    sidekiq_options queue: :scrape_and_update

    def perform(profile_id)
      profile = Profile.find_by(id: profile_id)
      return unless profile

      result = Profiles::ScrapeAndUpdate.call(profile)
      return unless result[:success]

      updated_profile = profile.reload
      updated_profile.broadcast_replace_to(
        updated_profile,
        target: dom_id(updated_profile, :live),
        partial: "profiles/show_content",
        locals: { profile: updated_profile }
      )
    end
  end
end
