class SiteMapper
  # Crawl result processor
  class CrawlResult
    # Create new CrawlResult from Faraday::Response
    #
    # @param response [Faraday::Reponse] Faraday response
    # @return [CrawlResult] New crawl result
    def initialize response
      @headers = response.headers
      @body = response.body
      @status = response.status
    end

    # Get the page contents from the result
    #
    # @return [String, nil] Html document on 200 success, funky link on
    #   redirect [301, 302], nil on other response status codes.
    def result
      if success? && html_content?
        @body
      elsif redirect?
        warn_redirect
        redirect_body
      end
    end

    # Check if the response is html content
    #
    # @return [Boolean] True for text/html, false otherwise.
    def html_content?
      content_type && content_type.include?('text/html')
    end

    # Get the content type from the response header
    #
    # @return [String] The content type of the response
    def content_type
      @headers['content-type']
    end

    # Check if the response was a success
    #
    # @return [Boolean] True for 200 response, false otherwise.
    def success?
      @status == 200
    end

    # Check if the response was a 301 or 302 redirect.
    #
    # @return [Boolean] True if the response was a 301 or 302 redirect, false
    #   for other status codes.
    def redirect?
      [301, 302].include? @status
    end

    # Convert the redirect location header to a regular link.
    #
    # This is done this way currently because the crawler has no idea or control
    # over the limits of what is crawled. The SiteMapper controlling the crawler
    # is what checks that the url is of the same host name. So we trick it into
    # thinking the page has a link to the redirect and if the location has the
    # same hostname, it gets crawled.
    #
    # @return [String] Html anchor linking to the redirect location
    def redirect_body
      "<a href=\"#{@headers['location']}\">redirect</a>"
    end

    # Print notice of redirect to stdout
    #
    # @return [nil]
    def warn_redirect
      message = "Redirected: #{@headers['location']}"
      puts message if ENV.fetch('SITE_MAPPER_VERBOSE', false)
    end
  end
end
