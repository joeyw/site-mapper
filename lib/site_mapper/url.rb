class SiteMapper
  # URL parser wrapped around URI to process and filter urls
  class URL
    # Initialize a new URL to process
    #
    # @param source_url [String] Source url of the document to be used as
    #   the base for relative urls.
    # @param url [String] Sting to parse and convert to a valid absolute url
    # @param source_tag [String] The html element tag the url was extract from
    # @return [SiteMapper::URL] New URL instance.
    def initialize source_url, url, source_tag
      @source_url = parse(source_url)
      @url = url
      @source_tag = source_tag
    end

    # Parse a url
    #
    # @param source_url [String] Source url of the document to be used as
    #   the base for relative urls.
    # @param url [String] Sting to parse and convert to a valid absolute url
    # @param source_tag [String] The html element tag the url was extract from
    # @return [String, nil] Processed url or nil for invalid url
    def self.parse source_url, url, source_tag
      new(source_url, url, source_tag).process
    end

    # Process the url into a usable absolue url
    #
    # @return [String, nil] Absolute URL for valid urls or nil
    def process
      return nil unless link_url?
      url = @url.dup
      if url = parse(url)
        return parse_relative_url unless url.host
        url.scheme ||= @source_url.scheme
        if same_source_host? || external_asset_url?
          URI.unescape(url.to_s, '%7C')
        end
      end
    end

    # Parse wrapper method for URI.parse
    #
    # @param url [String] Url to parse
    # @return [URI::HTTP, nil] URI object, nil on invalid uri
    def parse url
      begin
        uri = URI.parse URI.escape(url.to_s, '|')
        uri.fragment = nil
        uri
      rescue URI::InvalidURIError
        puts "Invalid URI: #{url}"
        nil
      end
    end

    # Parse the relative @url into an absolute url
    #
    # @return [String] Absolute url
    def parse_relative_url
      path = @url.dup
      path.prepend '/' unless path[0] == '/'
      url = parse "#{@source_url.scheme}://#{@source_url.host}#{path}"
      URI.unescape(url.to_s, '%7C')
    end

    # Check if the url is from a static asset and external source
    #
    # @return [Boolean] True of the url is different from the source host
    #   name and the url came from an html tag considered to be an asset tag.
    def external_asset_url?
      !same_source_host? && url_from_asset_tag?
    end

    # Check if the URL is from an html element considered to be a static asset.
    #
    # @return [Boolean] True if it is an asset, false if not.
    def url_from_asset_tag?
      !['a', 'area'].include?(@source_tag)
    end

    # Check if the URL is from the same host as the source url.
    #
    # @return [Boolean] True if the hosts are the same, false otherwise.
    def same_source_host?
      parse(@url).host == parse(@source_url).host
    end

    # Check if the URL is considered to be a link url.
    #
    # URLS not considered link urls:
    #
    # Hash links to element IDs on the same page. (#some-div)
    # Data URIs (data:image/png;base64...)
    # Email URIs (mailto:...)
    # Inline javascript URIs (javascript:{}()...)
    #
    # @return [Boolean] True if the link is considered a link url, false
    #   otherwise.
    def link_url?
      !id_link? && !data_uri? && !email_uri? && !js_uri?
    end

    # Check if the url is a anchor id link
    #
    # @return [Boolean] True if the url is only links to another elements dom
    #   ID on the same page as the source url.
    def id_link?
      @url[0] == '#'
    end

    # Check if the url is a data uri
    #
    # @return [Boolean] True if data uri, false otherwise.
    def data_uri?
      @url[0..4] == 'data:'
    end

    # Check if the url is an email link
    #
    # @return [Boolean] True if email link, false otherwise.
    def email_uri?
      @url[0..6] == 'mailto:'
    end

    # Check if the url value is inline javascript
    #
    # @return [Boolean] True if inline javascript, false otherwise.
    def js_uri?
      @url[0..10] == 'javascript:'
    end
  end
end
