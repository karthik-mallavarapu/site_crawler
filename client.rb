require_relative 'site'

#s = Site.new("http://www.news-summary.co/", 20)
s = Site.new("https://www.hackerschool.com/", 20)
s.crawl
s.page_rank
s.print_page_ranks
