require 'set'

class SiteMapper
  # SiteMaps handle the storage of site maps including the
  # links for a site as well as the asset urls.
  class SiteMap
    # Url of the website for which we want to make a site map
    # @return [String] Website Url
    attr_reader :site_url

    # Create a new SiteMap
    #
    # @param site_url [String] Value website url
    # @return [SiteMap] New SiteMap
    def initialize site_url
      @site_url = site_url
      @pages = {}
      @assets = {}
    end

    # All the pages mapped
    #
    # @return [Hash] Site map pages.
    def pages
      @pages
    end

    # All the static assets
    #
    # @return [Hash] Static assets.
    def assets
      @assets
    end

    # Add page to site map
    #
    # @param url [String] Url of the page being added.
    # @param links [Array] Links to add.
    # @param assets [Array] Asset urls to add.
    # @return [SiteMapper::SiteMap] The updated SiteMap.
    def add_page url, links, assets
      create_or_update_page url, links, assets
      links.each { |link| add_inbound_links_to_page url, link }
      assets.each { |asset| create_or_update_asset url, asset }
    end

    # Create a page or add additional links to a page in the SiteMap
    #
    # @param url [String] URL of the page
    # @param links [Array<String>] Links containing on the page
    # @param assets [Array<String>] Assets used by the page
    # @return [Hash] Page hash containing :outbound_links, :inbound_links, and
    #   :assets
    def create_or_update_page url, links, assets
      page = @pages[url] ||= {outbound_links: [], inbound_links: [], assets: []}
      page[:outbound_links].concat(links).uniq!
      page[:assets].concat(assets).uniq!
      @pages[url]
    end

    # Add an inbound link to a page
    #
    # @param page_url [String] The page containing the link.
    # @param link_url [String] The URL of the page being linked to.
    def add_inbound_links_to_page page_url, link_url
      add_page link_url, [], []
      inbound = @pages[link_url][:inbound_links]
      inbound.push page_url unless inbound.include? page_url
    end

    # Add (or create) an asset and dependent urls to the site map
    #
    # @param page_url [String] Url of the page containing the asset
    # @param asset_url [String] Url location of the asset
    def create_or_update_asset page_url, asset_url
      @assets[asset_url] ||= {dependent_urls: []}
      dependent_urls = @assets[asset_url][:dependent_urls]
      dependent_urls.push page_url unless dependent_urls.include? page_url
    end

    # Convert the SiteMap to a hash
    #
    # @return [Hash] Hash containing the sitemap :site_url, :pages, and :assets
    def to_h
      { site_url: @site_url, pages: @pages, assets: @assets }
    end
  end
end
