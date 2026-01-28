FactoryBot.define do
  factory :profile do
    association :user

    name { "Nome Exemplo" }
    github_url { "https://github.com/exemplo" }
    github_username { "exemplo" }
    followers_count { 10 }
    following_count { 5 }
    stars_count { 3 }
    contributions_last_year { 42 }
    avatar_url { "https://avatars.githubusercontent.com/u/1" }
    location { "Florianópolis, Brazil" }
    organization { "Minha Org" }
  end
end

