require 'set'
require 'faraday'
require 'site_mapper/crawl_result'

class SiteMapper
  # Our crawler that handles fetching web pages
  class Crawler

    # @return [String] Last url crawled.
    attr_reader :last_url

    # Fire up a new crawler
    #
    # @return [SiteMapper::Crawler] Fresh new ready, willing and able
    #   crawler.
    def initialize
      @queue = Set.new
      @crawled_urls = Set.new
    end

    # Add urls to the crawl queue
    #
    # @param url [Array<String>] Urls to crawl
    # @return [Set] Queued urls.
    def queue url
      @queue.add url unless @crawled_urls.include? url
    end

    # Check if the queue is empty
    #
    # @return [Boolean] Truthiness of the queue emptiness
    def empty_queue?
      @queue.empty?
    end

    # Crawl the next url in the queue
    #
    # @return [String] Response body on success, nil on erroneous response.
    def next
      return if empty_queue?
      data = CrawlResult.new crawl next_url
      data.result
    end

    # Perform a get request for a url
    #
    # @param url [String] URL to get.
    # @return [Faraday::Response] Response from the request.
    def crawl url
      puts "Crawling #{url}" if ENV.fetch('SITE_MAPPER_VERBOSE', false)
      response = Faraday.get url
      @last_url = url
      @crawled_urls.add url
      response
    end

    private

    # @private Get the next url to crawl
    #
    # @return [String] url
    def next_url
      url = @queue.first
      @queue.delete url
      url
    end
  end
end
