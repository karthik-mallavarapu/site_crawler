require 'nokogiri'
require 'uri'
require 'open-uri'

module Crawler

  EXCLUDE_PATTERN = /.(jpg|jpeg|png|gif|pdf|svg|mp4)\z/

  def scrape_page(url)
    page = get_page(url)
    return [] if page.nil?
    links = page.css('a')
    urls = links.map { |link|  link['href'] }
    urls.compact!
    urls.uniq!
    sanitize_urls(urls).compact.uniq
  end

  def get_page(url)
    begin
      page = Nokogiri::HTML(open(url))
    rescue Exception => e
      puts "Warning: Get page for #{url} resulted in #{e.message}"
    end
  end

  def sanitize_urls(urls)
    urls.map do |link|
      begin
        uri = URI(URI.encode(link))
        if uri.absolute? && uri.hostname == domain &&
        (uri.scheme == "http" || uri.scheme == "https")
          URI.decode(uri.to_s)
        elsif uri.relative?
          URI.decode(URI(URI.encode(base_url)).merge(uri).to_s)
        end
      rescue Exception => e
        puts "Warning: #{e.message}"
        next
      end
    end
  end

  def disallowed?(url)
    !!(url =~ EXCLUDE_PATTERN)
  end

  def reachable?(url)
    return true if get_page(url)
    false
  end

end
