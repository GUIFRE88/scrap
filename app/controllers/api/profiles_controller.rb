# frozen_string_literal: true

module Api
  class ProfilesController < BaseController
    include Api::PaginationParams

    def index
      result = Api::Profiles::List.call(**pagination_params)
      @profiles = result[:profiles]
      @meta = result[:meta]
    end

    def show
      result = Api::Profiles::Find.call(id: params[:id])
      @profile = result[:profile]
      @meta = result[:meta]
    end
  end
end

