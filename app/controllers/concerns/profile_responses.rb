# frozen_string_literal: true

module ProfileResponses
  extend ActiveSupport::Concern

  private

  def handle_create_success(result)
    if result[:scrape_success]
      redirect_to result[:profile], notice: "Perfil criado com sucesso."
    else
      flash[:alert] = "Perfil criado, mas houve erro ao extrair os dados do Github."
      redirect_to result[:profile]
    end
  end

  def handle_create_failure(result)
    @profile = result[:profile] || current_user.profiles.build(profile_params)
    flash.now[:alert] = "Não foi possível criar o perfil."
    render :new, status: :unprocessable_entity
  end

  def handle_update_success(result)
    if result[:scrape_success]
      redirect_to @profile, notice: "Perfil atualizado com sucesso."
    else
      flash[:alert] = "Perfil atualizado, mas houve erro ao extrair os dados do Github."
      redirect_to @profile
    end
  end

  def handle_update_failure(result)
    flash.now[:alert] = "Não foi possível atualizar o perfil."
    render :edit, status: :unprocessable_entity
  end
end
