module Api
  class ProfilesController < BaseController
    skip_before_action :authenticate_user!, only: [:index, :show]
    
    def index
      page = (params[:page] || 1).to_i
      per_page = (params[:per_page] || 10).to_i

      @profiles = Profile.paginate(page: page, per_page: per_page)

      @meta = {
        current_page: @profiles.current_page,
        per_page: per_page,
        total_pages: @profiles.total_pages,
        total_count: @profiles.total_entries
      }
    end

    def show
      @profile = Profile.find(params[:id])

      @meta = {
        current_page: 1,
        per_page: 1,
        total_pages: 1,
        total_count: 1
      }
    end
  end
end

