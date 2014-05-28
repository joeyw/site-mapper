require 'spec_helper'

# Site link and asset mapper
describe SiteMapper do
  describe ".map" do
    let (:uri) { 'http://digitalocean.com' }

    it "respect robots.txt and nofollow links" do
      pending "Skip for now"
      fail
    end

    it "skips crawlign known binary formats" do
      pending "The crawler gets every link but only parses html content"
      fail
    end

    it "handles more responses" do
      pending "Currently only 200, 301, 302 status codes are supposed"
      fail
    end

    it "handle bad connections" do
      pending "the crawler is fairly flakey, one bad connection and it crashes"
      fail
    end

    it "handles redirects better" do
      message = <<MESSAGE
A lot of webpages cant make up there minds if they want a trailing slash. Even
when they do redirect to include the trailing slash, they still dont put that
on their urls in their links. Currently site mapper considers redirects another
page with a link to the destination. It would be nice to connect the data
directly instead of needing to go through the url that initially redircted.
MESSAGE
      pending message
      fail
    end

    context "with single page site" do
      context "with no links nor assets" do
        before do
          stub_request(:get, "#{uri}/").
            to_return(status: 200, body: '<!doctype html><title></title>')
          @site_map = SiteMapper.map "#{uri}/"
        end

        it "requests the base url" do
          assert_requested :get, "#{uri}/"
        end

        it "returns the site map" do
          expect(@site_map).to be_kind_of SiteMapper::SiteMap
          expect(@site_map.site_url).to eq "#{uri}/"
        end

        it "returns a hash" do
          expect(@site_map.pages).to be_kind_of Hash
          expect(@site_map.pages.keys).to match_array ["#{uri}/"]
        end

        it "returns a hash" do
          expect(@site_map.assets).to be_kind_of Hash
          expect(@site_map.assets.keys).to eq []
        end
      end # with no links nor assets
    end # with single page site

    context "with three page site" do
      before do
        @base_request = stub_request(:get, uri).
          to_return status: 200, body: fixture('three-page-site/index.html'),
            headers: {'content-type' => 'text/html'}
        @careers_request = stub_request(:get, "#{uri}/careers").
          to_return status: 200, body: fixture('three-page-site/careers.html'),
            headers: {'content-type' => 'text/html'}
        @about_us_request = stub_request(:get, "#{uri}/careers/ruby-engineer").
          to_return status: 200,
                    body: fixture('three-page-site/ruby-engineer.html'),
                    headers: {'content-type' => 'text/html'}
        @site_map = SiteMapper.map uri
      end

      it "crawls all three pages" do
        assert_requested @base_request
        assert_requested @careers_request
        assert_requested @about_us_request
      end

      it "includes all three pages" do
        pages = @site_map.pages
        expect(pages.length).to eq 3
        expect(pages["#{uri}/"]).to be
        expect(pages["#{uri}/careers"]).to be
        expect(pages["#{uri}/careers/ruby-engineer"]).to be
      end
    end # with three page site
  end # .map
end # SiteMapper
