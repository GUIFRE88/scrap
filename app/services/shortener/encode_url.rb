module Shortener
  class EncodeUrl
    ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".freeze
    LENGTH = 8

    def self.call(profile, repository: ProfileRepository.new)
      new(profile, repository: repository).call
    end

    def initialize(profile, repository:)
      @profile = profile
      @repository = repository
    end

    def call
      return @profile.short_code if @profile.short_code.present?

      @profile.short_code = generate_unique_code
    end

    private

    attr_reader :repository

    def generate_unique_code
      loop do
        code = random_code
        break code unless repository.exists?(short_code: code)
      end
    end

    def random_code
      LENGTH.times.map { ALPHABET[rand(ALPHABET.size)] }.join
    end
  end
end

