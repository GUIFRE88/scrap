# frozen_string_literal: true

module Api
  module Profiles
    class Find
      def self.call(id:)
        new(id: id).call
      end

      def initialize(id:)
        @id = id
      end

      def call
        {
          profile: profile,
          meta: build_meta
        }
      end

      private

      attr_reader :id

      def profile
        @profile ||= Profile.find(id)
      end

      def build_meta
        {
          current_page: 1,
          per_page: 1,
          total_pages: 1,
          total_count: 1
        }
      end
    end
  end
end
