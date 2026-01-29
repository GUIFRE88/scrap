# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :authenticate_user!
    skip_before_action :set_locale
    
    before_action :authenticate_api_user!

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def authenticate_api_user!
      token = extract_token_from_header
      
      unless token.present?
        render_unauthorized('Token de autenticação não fornecido')
        return
      end

      @current_api_user = User.find_by(api_token: token)
      
      unless @current_api_user
        render_unauthorized('Token inválido')
        return
      end
    end

    def current_api_user
      @current_api_user
    end

    def extract_token_from_header
      request.headers['Authorization']&.gsub(/^Bearer /, '')
    end

    def render_not_found
      render json: { error: 'Not Found' }, status: :not_found
    end

    def render_unauthorized(message)
      render json: { error: message }, status: :unauthorized
    end
  end
end

