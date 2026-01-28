json.data @profiles do |profile|
  json.id profile.id
  json.name profile.name
  json.github_username profile.github_username
  json.short_github_url profile.short_github_url
  json.followers profile.followers_count
  json.following profile.following_count
  json.stars profile.stars_count
  json.contributions_last_year profile.contributions_last_year
  json.avatar_url profile.avatar_url
  json.location profile.location
  json.organizations profile.organizations_array
end

json.meta do
  json.current_page @meta[:current_page]
  json.per_page @meta[:per_page]
  json.total_pages @meta[:total_pages]
  json.total_count @meta[:total_count]
end

