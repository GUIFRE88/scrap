# frozen_string_literal: true

module Api
  module PaginationParams
    extend ActiveSupport::Concern

    private

    def pagination_params
      {
        page: params[:page],
        per_page: params[:per_page]
      }
    end
  end
end
