require 'spec_helper'

describe SiteMapper::SiteMap do
  let (:uri) { 'https://digitalocean.com' }

  before do
    @site_map = SiteMapper::SiteMap.new uri
  end

  describe ".site_url" do
    it "returns the site_url" do
      expect(@site_map.site_url).to eq uri
    end

    it "is read only" do
      expect {
        @site_map.site_url = 'error me out'
      }.to raise_error NoMethodError
    end
  end # .site_url

  describe ".pages" do
    it "returns a hash" do
      expect(@site_map.pages).to be_kind_of Hash
    end
  end # .pages

  describe ".assets" do
    it "returns a hash" do
      expect(@site_map.assets).to be_kind_of Hash
    end
  end # .assets

  describe ".to_h" do
    it "returns a hash of the site map" do
      site_map = @site_map.to_h
      expect(site_map).to be_kind_of Hash
      expect(site_map[:assets]).to be_kind_of Hash
      expect(site_map[:pages]).to be_kind_of Hash
      expect(site_map[:site_url]).to eq uri
    end
  end

  describe ".add" do
    context "with empty site map" do
      it "adds a page" do
        @site_map.add_page uri, [], []
        expect(@site_map.pages).to include uri
      end

      it "adds urls to a page" do
        @site_map.add_page uri, ["#{uri}/careers"], []
        outbound_links = @site_map.pages[uri][:outbound_links]
        expect(outbound_links).to include "#{uri}/careers"
      end

      it "adds assets to a page" do
        @site_map.add_page uri, [], ["#{uri}/main.js"]
        expect(@site_map.pages[uri][:assets]).to include "#{uri}/main.js"
      end

      it "adds a new asset entry" do
        @site_map.add_page uri, [], ["#{uri}/main.js"]
        expect(@site_map.assets).to include "#{uri}/main.js"
      end

      it "adds page as an asset dependency" do
        @site_map.add_page uri, [], ["#{uri}/main.js"]
        asset = @site_map.assets["#{uri}/main.js"]
        expect(asset[:dependent_urls]).to include uri
      end
    end # with empty site map

    context "with site map" do
      before do
        links = ["#{uri}/about-us", "#{uri}/careers", "#{uri}/ruby-engineer"]
        assets = ["#{uri}/main.css", "#{uri}/index.js"]
        @site_map.add_page uri, links, assets
      end

      it "doesn't duplicate existing pages" do
        expect { @site_map.add_page uri, [], [] }.
          to_not change { @site_map.pages.size }
      end

      it "initializes linked page" do
        expect {
          @site_map.add_page uri, ["#{uri}/features"], []
        }.to change {
          @site_map.pages.size
        }.by 1
      end

      it "adds inbound links from current page to target pages" do
        expect {
          @site_map.add_page "#{uri}/contact-us", ["#{uri}/careers"], []
        }.to change {
          @site_map.pages["#{uri}/careers"][:inbound_links].size
        }.by 1
      end

      it "doesn't duplicate assets" do
        expect {
          @site_map.add_page uri, [], ["#{uri}/index.js"]
        }.to_not change {
          @site_map.assets.size
        }
      end
    end
  end
end # SiteMapper::SiteMap
