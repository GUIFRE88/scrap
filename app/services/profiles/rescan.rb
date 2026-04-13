# frozen_string_literal: true

module Profiles
  class Rescan
    def self.call(profile:)
      new(profile: profile).call
    end

    def initialize(profile:)
      @profile = profile
    end

    def call
      Profiles::ScrapeAndUpdateJob.perform_async(@profile.id)

      {
        success: true,
        message: "Re-escaneamento enfileirado com sucesso."
      }
    rescue StandardError => e
      Rails.logger.error("[Profiles::Rescan] Error: #{e.message}")
      { success: false, message: "Erro ao re-escanear perfil: #{e.message}" }
    end

  end
end
