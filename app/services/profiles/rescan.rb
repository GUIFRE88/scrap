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
      result = Profiles::ScrapeAndUpdate.call(@profile)
      
      {
        success: result[:success],
        message: result[:message] || (result[:success] ? "Perfil re-escaneado com sucesso." : "Erro ao re-escanear perfil.")
      }
    rescue StandardError => e
      Rails.logger.error("[Profiles::Rescan] Error: #{e.message}")
      { success: false, message: "Erro ao re-escanear perfil: #{e.message}" }
    end
  end
end
