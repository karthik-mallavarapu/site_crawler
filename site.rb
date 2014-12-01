require_relative 'crawler'

class Site

  include Crawler

  attr_reader :pages, :base_url, :domain

  INIT_PAGE_RANK = 1
  DAMP_FACTOR = 0.85

  def initialize(url, url_limit=50)
    @base_url = url
    @url_limit = url_limit
    @domain = URI(URI.encode(@base_url)).hostname
    @pages = []
    @pages_to_visit = []
    @inbound_pages = Hash.new { [] }
    @outbound_page_counts = Hash.new(1)
    @page_ranks = {}
    enqueue(@base_url)
  end

  def crawl
    while (!queue_empty? and page_visit_len < @url_limit) do
      url = dequeue
      unless ignorable?(url)
        visit_page(url)
        urls = scrape_page(url)
        save_outbound_count(url, urls.size)
        urls.each do |u|
          enqueue(u)
          save_inbound_page(url, u)
        end
      end
    end
  end

  def page_rank
    pages.each do |page|
      @page_ranks[page] = INIT_PAGE_RANK
    end
    30.times do
      pages.each do |page|
        temp_pr = 0
        @inbound_pages[page].each do |inbound|
          temp_pr += @page_ranks[inbound] / @outbound_page_counts[inbound]
        end
        @page_ranks[page] = (1 - DAMP_FACTOR) + DAMP_FACTOR * temp_pr
      end
    end
    @page_ranks = Hash[@page_ranks.sort_by { |k, v| v }.reverse]
  end

  def print_pages
    @pages.each do |page|
      puts page
    end
  end

  def print_page_ranks
    @page_ranks.each do |page, score|
      puts "#{page} ....... #{score}"
    end
  end

  private

  def visited? (url)
    @pages.include? url
  end

  def ignorable?(url)
    visited?(url) || disallowed?(url) || !reachable?(url) || fragmented?(url)
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

  def save_outbound_count(url, count)
    @outbound_page_counts[url] = count
  end

  def save_inbound_page(current_url, outbound_url)
    @inbound_pages[outbound_url] += [current_url]
  end

  def enqueue(url)
    @pages_to_visit << url unless @pages_to_visit.include? url
  end

  def dequeue
    @pages_to_visit.shift
  end

end
