module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :authenticate_user!
    skip_before_action :set_locale
    
    before_action :authenticate_api_user!

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def authenticate_api_user!
      token = request.headers['Authorization']&.gsub(/^Bearer /, '')
      
      unless token.present?
        render json: { error: 'Token de autenticação não fornecido' }, status: :unauthorized
        return
      end

      @current_api_user = User.find_by(api_token: token)
      
      unless @current_api_user
        render json: { error: 'Token inválido' }, status: :unauthorized
        return
      end
    end

    def current_api_user
      @current_api_user
    end

    def render_not_found
      render json: { error: 'Not Found' }, status: :not_found
    end
  end
end

