class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show edit update destroy rescan]
  before_action :ensure_profile_owner, only: %i[show edit update destroy rescan]

  def index
    @query = params[:q]
    @profiles = current_user.profiles.search(@query).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def show; end

  def new
    @profile = current_user.profiles.build
  end

  def create
    @profile = current_user.profiles.build(profile_params)
    Shortener::EncodeUrl.call(@profile)

    if @profile.save
      result = Profiles::ScrapeAndUpdate.call(@profile)
      if result[:success]
        redirect_to @profile, notice: "Perfil criado com sucesso."
      else
        flash[:alert] = "Perfil criado, mas houve erro ao extrair os dados do Github."
        redirect_to @profile
      end
    else
      flash.now[:alert] = "Não foi possível criar o perfil."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @profile.update(profile_params)
      result = Profiles::ScrapeAndUpdate.call(@profile)
      if result[:success]
        redirect_to @profile, notice: "Perfil atualizado com sucesso."
      else
        flash[:alert] = "Perfil atualizado, mas houve erro ao extrair os dados do Github."
        redirect_to @profile
      end
    else
      flash.now[:alert] = "Não foi possível atualizar o perfil."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to dashboard_path, notice: "Perfil removido com sucesso."
  end

  def rescan
    result = Profiles::ScrapeAndUpdate.call(@profile)
    if result[:success]
      redirect_to @profile, notice: "Perfil re-escaneado com sucesso."
    else
      redirect_to @profile, alert: "Erro ao re-escanear perfil: #{result[:message]}"
    end
  end

  def redirect
    profile = Profile.find_by!(short_code: params[:short_code])
    redirect_to profile.github_url, allow_other_host: true
  end

  private

  def set_profile
    @profile = current_user.profiles.find(params[:id])
  end

  def ensure_profile_owner
    return if @profile.user_id == current_user.id

    redirect_to dashboard_path, alert: "Você não tem permissão para acessar este perfil."
  end

  def profile_params
    params.require(:profile).permit(:name, :github_url)
  end
end

