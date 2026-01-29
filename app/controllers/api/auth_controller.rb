module Api
  class AuthController < BaseController
    skip_before_action :authenticate_api_user!

    def create
      email = params[:email]
      password = params[:password]

      unless email.present? && password.present?
        render json: { error: 'Email e senha são obrigatórios' }, status: :bad_request
        return
      end

      user = User.find_by(email: email)

      if user&.valid_password?(password)
        user.generate_api_token if user.api_token.blank?
        user.save

        render json: {
          token: user.api_token,
          user: {
            id: user.id,
            email: user.email
          }
        }, status: :ok
      else
        render json: { error: 'Credenciais inválidas' }, status: :unauthorized
      end
    end
  end
end
