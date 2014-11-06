require_relative 'spec_helper'
require_relative '../site'

describe Site do

  before do
    @client = Site.new("http://www.news-summary.co", 5)
    @relevant_pages = [@client.base_url, "#{@client.base_url}/national", "#{@client.base_url}/world",
    "#{@client.base_url}/sports", "#{@client.base_url}/business"]
    @external_pages = ["https://twitter.com/newssummary",
      "https://www.facebook.com/newssummary"]
    body = ""
    @relevant_pages.
    each_with_index { |page, index| body += "<a href='#{page}'>Link#{index}</a>"}
    @external_pages.
    each_with_index { |page, index| body += "<a href='#{page}'>Link#{index}</a>"}
    stub_request(:get, "http://www.news-summary.co").
    to_return(:status => 200, :body => body, :headers => {})

    stub_request(:get, /http:\/\/www.news-summary.co\/.+/).
    to_return(:status => 200, :body => "", :headers => {})
    @client.crawl
  end


  it "has pages with urls matching the hostname" do
    expect(@client.pages).to eq @relevant_pages
  end

  it "ignores external urls" do
    @external_pages.each do |page|
      expect(@client.pages.include? page).to eq false
    end
  end

  it "returns the hostname" do
    expect(@client.domain).to eq "www.news-summary.co"
  end


end
