# frozen_string_literal: true

module Profiles
  class Rescan
    def self.call(profile:, repository: ProfileRepository.new)
      new(profile: profile, repository: repository).call
    end

    def initialize(profile:, repository:)
      @profile = profile
      @repository = repository
    end

    def call
      result = Profiles::ScrapeAndUpdate.call(@profile, repository: repository)
      
      {
        success: result[:success],
        message: result[:message] || (result[:success] ? "Perfil re-escaneado com sucesso." : "Erro ao re-escanear perfil.")
      }
    rescue StandardError => e
      Rails.logger.error("[Profiles::Rescan] Error: #{e.message}")
      { success: false, message: "Erro ao re-escanear perfil: #{e.message}" }
    end

    private

    attr_reader :repository
  end
end
