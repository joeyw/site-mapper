require 'site_mapper/crawler'
require 'site_mapper/site_map'
require 'site_mapper/parser'

# SiteMapper is a tool for generating link and asset maps for websites.
class SiteMapper
  # Start a new SiteMapper
  #
  # @param url [String] Website url to generate a sitemap for.
  # @return [SiteMapper::SiteMap] Returns a SiteMap with the
  #   resulting data.
  def initialize url
    @url = URI.parse(url).to_s
    @site_map = SiteMap.new @url
    @crawler = SiteMapper::Crawler.new
    @crawler.queue initial_url
  end

  # Adds a slash to the initial url path if there is none
  #
  # @return [String] Starting url with a trailing slash.
  def initial_url
    if URI.parse(@url).path == ''
      "#{@url}/"
    else
      @url
    end
  end

  # Generate the SiteMap
  #
  # @return [SiteMapper::SiteMap] The site map.
  def map
    crawl until @crawler.empty_queue?
    @site_map
  end

  # Crawl and process the next url in the crawler queue
  #
  # @return [nil]
  def crawl
    parser = Parser.new @url.to_s, @crawler.next
    link_urls = parser.link_urls
    link_urls.each { |link_url| @crawler.queue link_url }
    @site_map.add_page @crawler.last_url, link_urls, parser.asset_urls
  end

  # Generate a sitemap for a given url.
  #
  # @param url [String] Url of a website to crawl and generate a site map.
  # @return [SiteMapper::SiteMap] SiteMap container with the site map of
  #   the given url.
  def self.map url
    new(url).map
  end
end
