require_relative 'crawler'
 
class Site

  include Crawler

  attr_reader :pages, :base_url, :domain

  def initialize(url, url_limit=50)
    @base_url = url
    @url_limit = url_limit
    @domain = URI(URI.encode(@base_url)).hostname
    @pages = []
    @pages_to_visit = []
    enqueue(@base_url)
  end

  def crawl
    while (!queue_empty? and page_visit_len < @url_limit) do
      url = dequeue
      unless ignorable?(url)
        visit_page(url)
        urls = scrape_page(url)
        urls.each { |u| enqueue(u) }
      end
    end
  end

  def print_pages
    @pages.each do |page|
      puts page
    end
  end

  private

  def visited? (url)
    @pages.include? url
  end

  def ignorable?(url)
    visited?(url) || disallowed?(url) || !reachable?(url)
  end

  def queue_empty?
    @pages_to_visit.empty?
  end

  def page_visit_len
    @pages.length
  end

  def visit_page(url)
    @pages << url
  end

  def enqueue(url)
    @pages_to_visit << url unless @pages_to_visit.include? url
  end

  def dequeue
    @pages_to_visit.shift
  end

end
