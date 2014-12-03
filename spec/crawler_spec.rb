require_relative 'spec_helper'
require_relative '../crawler'

describe Crawler do

  class CrawlerClient
    include Crawler

    attr_reader :base_url, :domain

    def initialize
      @base_url = "http://www.news-summary.co"
      @domain = URI(URI.encode(@base_url)).hostname
    end

  end

  before(:all) do
    @client = CrawlerClient.new
  end

  describe "#disallowed?" do

    ["png", "pdf", "svg", "jpg", "jpeg", "gif", "mp4"].each do |file_ext|

      it "disallows url if it is a static file" do
        disallowed = @client.disallowed?("http://www.example.com/static/file.#{file_ext}")
        expect(disallowed).to eq true
      end

    end

  end

  describe "#get_page" do

    before do
      stub_request(:get, "http://www.news-summary.co").
      to_return(:status => 200, :body => "", :headers => {})
      stub_request(:get, "http://www.invalidrequest.com").
      to_return(:status => 404, :body => "", :headers => {})
    end

    it "returns a nokogiri object on successful request" do
      page = @client.get_page("http://www.news-summary.co")
      expect(page.class).to eq Nokogiri::HTML::Document
    end

    it "returns a nil object for a failed request" do
      page = @client.get_page("http://www.invalidrequest.com")
      expect(page).to eq nil
    end

  end

  describe "#reachable?" do

    context "when status code is client or server error" do

      [404, 422, 500].each do |status|

        it "returns false" do
          stub_request(:get, "http://www.news-summary.co").
          to_return(:status => status, :body => "", :headers => {})
          reachability = @client.reachable? ("http://www.news-summary.co/")
          expect(reachability).to eq false
        end

      end

    end

    context "when status code is ok" do
      [200, 204, 206].each do |status|

        it "returns true" do
          stub_request(:get, "http://www.news-summary.co").
          to_return(:status => status, :body => "", :headers => {})
          reachability = @client.reachable? ("http://www.news-summary.co/")
          expect(reachability).to eq true
        end

      end
    end

  end

  describe "#sanitize_urls" do

    { "/site1" => "/site1", "site2" => "/site2" }.
    each do |url, result|

      it "transforms a relative url to an absolute url" do
        transformed_url = @client.sanitize_urls([url]).join
        expect(transformed_url).to eq "#{@client.base_url}#{result}"
      end

    end

    [ "http://www.news-summary.com/site1", "http://twitter.com/", "http://www.facebook.com"].each do |url|

      it "ignores a url if hostname does not match" do
        transformed_url = @client.sanitize_urls([url]).join
        expect(transformed_url).to eq ""
      end

    end

  end

  describe "#scrape_page" do

    before do
      body = "<a href='#{@client.base_url}/national'>National</a>
      <a href='/world'>World</a>
      <a href='sports'>Sports</a>
      <a href='#{@client.base_url}/business'>Business</a>
      <a href='https://twitter.com/newssummary'>News-Summary Twitter</a>
      <a href='https://www.facebook.com/newssummary'>News-Summary FB</a>"

      stub_request(:get, "http://www.news-summary.co").
      to_return(:status => 200, :body => body, :headers => {})

      @expected_result = ["#{@client.base_url}/national",
        "#{@client.base_url}/world",
        "#{@client.base_url}/sports",
        "#{@client.base_url}/business"]
      @actual_result = @client.scrape_page(@client.base_url)
    end

    it "returns list of links from the page" do
      expect(@actual_result).to eq @expected_result
    end

    ["https://www.facebook.com/newssummary", "https://twitter.com/newssummary"].
    each do |url|

      it "ignores links not matching the hostname" do
        expect(@actual_result.include? url).not_to eq true
      end

    end

  end

end
