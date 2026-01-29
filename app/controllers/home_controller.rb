# frozen_string_literal: true

class HomeController < ApplicationController
  def dashboard
    result = Profiles::DashboardList.call(
      user: current_user,
      query: params[:q],
      page: params[:page],
      per_page: params[:per_page]
    )
    
    @profiles = result[:profiles]
    @query = result[:query]
  end
end
