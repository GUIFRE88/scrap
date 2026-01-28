module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def render_not_found
      render json: { error: 'Not Found' }, status: :not_found
    end
  end
end

