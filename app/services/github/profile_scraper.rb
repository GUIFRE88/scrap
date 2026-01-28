require "httparty"
require "nokogiri"

module Github
  class ProfileScraper
    class Error < StandardError; end

    class << self
      def call(github_url)
        html = fetch_html(github_url)
        parse_profile(html)
      rescue StandardError => e
        Rails.logger.error("[Github::ProfileScraper] Error while scraping #{github_url}: #{e.message}")
        raise Error, e.message
      end

      private

      def fetch_html(url)
        response = HTTParty.get(url)
        raise Error, "Status code #{response.code}" unless response.success?

        response.body
      end

      def parse_profile(html)
        doc = Nokogiri::HTML(html)

        {
          github_username: extract_username(doc),
          followers_count: extract_number(doc, 'a[href$="?tab=followers"] .text-bold'),
          following_count: extract_number(doc, 'a[href$="?tab=following"] .text-bold'),
          stars_count: extract_stars(doc),
          contributions_last_year: extract_contributions(doc),
          avatar_url: extract_avatar_url(doc),
          organization: extract_optional_text(doc, '.p-org'),
          location: extract_optional_text(doc, '.p-label')
        }
      end

      def extract_username(doc)
        doc.css('span.p-nickname.vcard-username.d-block').text.strip.presence
      end

      def extract_number(doc, selector)
        text = doc.css(selector).text.strip
        normalized = text.gsub(",", "").gsub(".", "").gsub("k", "000")
        Integer(normalized)
      rescue ArgumentError, TypeError
        0
      end

      def extract_stars(doc)
        stars_link = doc.at_css('a[href$="?tab=stars"]')
        return 0 unless stars_link

        # Procura pelo span.Counter dentro do link (formato atual do Github)
        counter = stars_link.at_css('span.Counter') ||
                  stars_link.at_css('span[data-component="counter"] span[aria-hidden="true"]') ||
                  stars_link.at_css('span[aria-hidden="true"]') ||
                  stars_link.at_css('span.prc-CounterLabel') ||
                  stars_link.at_css('.text-bold')

        return 0 unless counter

        text = counter.text.strip
        normalized = text.gsub(",", "").gsub(".", "").gsub("k", "000")
        Integer(normalized)
      rescue ArgumentError, TypeError
        0
      end

      def extract_contributions(doc)
        text = doc.at_css('h2.f4.text-normal.mb-2')&.text.to_s
        match = text.match(/(\d[\d,\.]*)\s+contributions/i)
        return 0 unless match

        match[1].gsub(/[,\.+]/, "").to_i
      end

      def extract_avatar_url(doc)
        doc.at_css('img.avatar-user')&.[]("src")
      end

      def extract_optional_text(doc, selector)
        value = doc.css(selector).text.strip
        value.presence
      end
    end
  end
end

