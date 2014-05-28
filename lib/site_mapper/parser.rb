require 'nokogiri'
require 'site_mapper/url'

class SiteMapper
  # Html parser and url extractor class extroidinaire.
  class Parser
    # Initialize a parser for an html document
    #
    # @param url [String] Source Url of the page
    # @param html [String] Html document
    # @return [SiteMapper::Parser] New parser
    def initialize url, html
      @page_url = URI.parse url
      @doc = Nokogiri::HTML html
    end

    # Get urls from a tags
    #
    # @return [Array<String>] Array of urls
    def a_tag_urls
      urls 'a', 'href'
    end

    # Get urls from area tags
    #
    # @return [Array<String>] Array of urls
    def area_tag_urls
      urls 'area', 'href'
    end

    # Get urls from link tags
    #
    # @return [Array<String>] Array of urls
    def link_tag_urls
      urls 'link', 'href'
    end

    # Get urls from img tags
    #
    # @return [Array<String>] Array of urls
    def img_tag_urls
      urls 'img', 'src'
    end

    # Get urls from embed tags
    #
    # @return [Array<String>] Array of urls
    def embed_tag_urls
      urls 'embed', 'src'
    end

    # Get urls from object tags
    #
    # @return [Array<String>] Array of urls
    def object_tag_urls
      urls 'object', 'data'
    end

    # Get urls from video tags
    #
    # @return [Array<String>] Array of urls
    def video_tag_urls
      urls 'video', 'src'
    end

    # Get urls from track tags
    #
    # @return [Array<String>] Array of urls
    def track_tag_urls
      urls 'track', 'src'
    end

    # Get urls from audio tags
    #
    # @return [Array<String>] Array of urls
    def audio_tag_urls
      urls 'audio', 'src'
    end

    # Get urls from source tags
    #
    # @return [Array<String>] Array of urls
    def source_tag_urls
      urls 'source', 'src'
    end

    # Get urls from script tags
    #
    # @return [Array<String>] Array of urls
    def script_tag_urls
      urls 'script', 'src'
    end

    # Get all urls from asset tags
    #
    # @return [Array<String>] Array of urls
    def asset_urls
      [
        link_tag_urls,
        img_tag_urls,
        embed_tag_urls,
        object_tag_urls,
        video_tag_urls,
        track_tag_urls,
        audio_tag_urls,
        source_tag_urls,
        script_tag_urls
      ].flatten
    end

    # Get all urls from link tags
    #
    # @return [Array<String>] Array of urls
    def link_urls
      [a_tag_urls, area_tag_urls].flatten
    end

    # Get parsed and processed urls from the html document.
    #
    # @param tag [String] Html element tag
    # @param url_attribute [String] Name of attribute containing the url
    # @return [Array<String>] Array of valid absolute urls
    def urls tag, url_attribute
      extract_urls(tag, url_attribute).map { |url|
        URL.parse @page_url, url, tag
      }.compact.
        uniq
    end

    # Extract urls from html elements in the document
    #
    # @param tag [String] Html element tag
    # @param url_attribute [String] Name of attribute containing the url
    # @return [Array<String>] Array of urls
    def extract_urls tag, url_attribute
      @doc.xpath("//#{tag}").map do |element|
        attr = element.attributes[url_attribute]
        next unless attr
        attr.value
      end.compact
    end
  end
end
