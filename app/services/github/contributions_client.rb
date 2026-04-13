module Github
  class ContributionsClient
    ENDPOINT = "https://api.github.com/graphql"
    USERNAME_FORMAT = /\A[a-zA-Z0-9-]+\z/

    def self.fetch(username)
      return 0 unless username.to_s.match?(USERNAME_FORMAT)

      query = <<~GRAPHQL
        query($login: String!) {
          user(login: $login) {
            contributionsCollection {
              contributionCalendar {
                totalContributions
              }
            }
          }
        }
      GRAPHQL

      response = HTTParty.post(
        ENDPOINT,
        headers: {
          "Authorization" => "Bearer #{ENV['API_TOKEN']}",
          "Content-Type" => "application/json"
        },
        body: { query: query, variables: { login: username } }.to_json
      )

      response
        .dig("data", "user", "contributionsCollection",
             "contributionCalendar", "totalContributions") || 0
    rescue StandardError
      0
    end
  end
end