require_relative 'site'

s = Site.new("http://www.news-summary.co/", 20)
s.crawl
s.print_pages
