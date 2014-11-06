require_relative 'site'

s = Site.new("https://www.hackerschool.com/", 20)
s.crawl
s.print_pages
