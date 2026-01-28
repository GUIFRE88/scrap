class HomeController < ApplicationController
  def dashboard
    @query = params[:q]
    @profiles = current_user.profiles.search(@query).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end
end
