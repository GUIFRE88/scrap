module Github
    class ContributionsClient
      ENDPOINT = "https://api.github.com/graphql"
  
      def self.fetch(username)
        query = <<~GRAPHQL
        {
          user(login: "#{username}") {
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
          body: { query: query }.to_json
        )

        response
          .dig("data", "user", "contributionsCollection",
               "contributionCalendar", "totalContributions") || 0
      rescue StandardError
        0
      end
    end
  end