# frozen_string_literal: true

class ProfileRepository
  def save(profile)
    profile.save
  end

  def update(profile, attributes)
    profile.update(attributes)
  end

  def update!(profile, attributes)
    profile.update!(attributes)
  end

  def destroy(profile)
    profile.destroy
  end

  def build(user, attributes)
    user.profiles.build(attributes)
  end

  def find(id)
    Profile.find(id)
  end

  def exists?(conditions)
    Profile.exists?(conditions)
  end

  def paginate(page:, per_page:)
    Profile.paginate(page: page, per_page: per_page)
  end

  def user_profiles(user)
    user.profiles
  end
end
