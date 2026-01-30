# frozen_string_literal: true

module Api
  class ProfilesController < BaseController
    include Api::PaginationParams

    def index
      result = Api::Profiles::List.call(user: current_api_user, **pagination_params)
      @profiles = result[:profiles]
      @meta = result[:meta]
    end

    def show
      result = Api::Profiles::Find.call(user: current_api_user, id: params[:id])
      @profile = result[:profile]
      @meta = result[:meta]
    end
  end
end

