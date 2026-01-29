# frozen_string_literal: true

class ProfilesController < ApplicationController
  include ProfileResponses

  before_action :set_profile, only: %i[show edit update destroy rescan]
  before_action :ensure_profile_owner, only: %i[show edit update destroy rescan]

  def index
    result = Profiles::DashboardList.call(
      user: current_user,
      query: params[:q],
      page: params[:page],
      per_page: params[:per_page]
    )
    
    @profiles = result[:profiles]
    @query = result[:query]
  end

  def show; end

  def new
    @profile = current_user.profiles.build
  end

  def create
    result = Profiles::Create.call(
      user: current_user,
      profile_params: profile_params
    )

    if result[:success]
      @profile = result[:profile]
      handle_create_success(result)
    else
      handle_create_failure(result)
    end
  end

  def edit; end

  def update
    result = Profiles::Update.call(
      profile: @profile,
      profile_params: profile_params
    )

    if result[:success]
      handle_update_success(result)
    else
      handle_update_failure(result)
    end
  end

  def destroy
    result = Profiles::Destroy.call(profile: @profile)
    
    if result[:success]
      redirect_to dashboard_path, notice: "Perfil removido com sucesso."
    else
      redirect_to dashboard_path, alert: "Erro ao remover perfil: #{result[:error]}"
    end
  end

  def rescan
    result = Profiles::Rescan.call(profile: @profile)
    
    if result[:success]
      redirect_to @profile, notice: result[:message]
    else
      redirect_to @profile, alert: result[:message]
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

