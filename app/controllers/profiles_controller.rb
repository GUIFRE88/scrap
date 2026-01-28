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
      run_scraper(@profile)
      redirect_to @profile, notice: "Perfil criado com sucesso."
    else
      flash.now[:alert] = "Não foi possível criar o perfil."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @profile.update(profile_params)
      run_scraper(@profile)
      redirect_to @profile, notice: "Perfil atualizado com sucesso."
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
    run_scraper(@profile)
    redirect_to @profile, notice: "Perfil re-escaneado com sucesso."
  rescue Github::ProfileScraper::Error => e
    redirect_to @profile, alert: "Erro ao re-escanear perfil: #{e.message}"
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

  def run_scraper(profile)
    data = Github::ProfileScraper.call(profile.github_url)
    profile.update!(
      github_username: data[:github_username],
      followers_count: data[:followers_count],
      following_count: data[:following_count],
      stars_count: data[:stars_count],
      contributions_last_year: data[:contributions_last_year],
      avatar_url: data[:avatar_url],
      organization: data[:organization],
      location: data[:location],
      last_scanned_at: Time.current
    )
  rescue Github::ProfileScraper::Error => e
    Rails.logger.error("[ProfilesController] Scraper error for #{profile.github_url}: #{e.message}")
    flash[:alert] = "Perfil salvo, mas houve erro ao extrair os dados do Github."
  end
end

