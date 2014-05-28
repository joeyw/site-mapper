require 'spec_helper'

describe SiteMapper::Crawler do
  let (:uri) { 'http://digitalocean.com' }

  describe ".queue" do
    context "with uncrawled url" do
      before do
        @request = stub_request(:get, uri).to_return status: 200, body: 'body'
        @crawler = SiteMapper::Crawler.new
      end

      it "queues a url to be crawled" do
        @crawler.queue uri
        @crawler.next
        assert_requested @request
      end
    end # with uncrawled url

    context "with queued url" do
      before do
        stub_request(:get, uri).to_return status: 200, body: 'body'
        @crawler = SiteMapper::Crawler.new
        @crawler.queue uri
      end

      it "doesn't queue duplicate url" do
        @crawler.queue uri
        @crawler.next
        expect(@crawler.next).to be_nil
      end
    end # with queued url

    context "with previously crawled url" do
      before do
        stub_request(:get, uri).to_return status: 200, body: 'body'
        @crawler = SiteMapper::Crawler.new
        @crawler.queue uri
        @crawler.next
      end

      it "does not queue the url to be crawled" do
        @crawler.queue uri
        expect(@crawler.next).to be_nil
      end
    end # with previously crawled url
  end # .queue_crawl

  describe ".last_url" do
    context "with last_url" do
      before do
        stub_request(:get, uri).to_return status: 200, body: 'body'
        @crawler = SiteMapper::Crawler.new
        @crawler.queue uri
        @crawler.next
      end

      it "returns the last url crawled" do
        expect(@crawler.last_url).to eq uri
      end
    end # with last_url

    context "without last_url" do
      it "returns nil" do
        crawler = SiteMapper::Crawler.new
        expect(crawler.last_url).to eq nil
      end
    end # without last_url
  end # .last_url

  describe ".empty_queue?" do
    context "with empty queue" do
      it "returns true" do
        crawler = SiteMapper::Crawler.new
        expect(crawler.empty_queue?).to eq true
      end
    end # with empty queue

    context "with items in the queue" do
      it "returns false" do
        crawler = SiteMapper::Crawler.new
        crawler.queue 'http://google.com'
        expect(crawler.empty_queue?).to eq false
      end
    end # with items in the queue
  end # .empty_queue?

  describe ".next" do
    context "with empty queue" do
      it "returns nil" do
        crawler = SiteMapper::Crawler.new
        expect(crawler.next).to be_nil
      end
    end # with empty queue

    context "with no content type response header" do
      before do
        @request = stub_request(:get, uri).
          to_return status: 200, body: 'response body'
        @crawler = SiteMapper::Crawler.new
        @crawler.queue uri
      end

      it "requests the next url" do
        expect(@crawler.next).to be_nil
      end
    end

    context "with non text/html content type response" do
      before do
        @request = stub_request(:get, uri).
          to_return status: 200, body: 'response body',
            headers: {'content-type' => 'text/xml'}
        @crawler = SiteMapper::Crawler.new
        @crawler.queue uri
      end

      it "requests the next url" do
        expect(@crawler.next).to be_nil
      end
    end # with non text/html content type response

    context "with queue" do
      before do
        @request = stub_request(:get, uri).
          to_return status: 200, body: 'response body',
            headers: {'content-type' => 'text/html'}
        @crawler = SiteMapper::Crawler.new
        @crawler.queue uri
      end

      it "requests the next url" do
        @crawler.next
        assert_requested @request
      end

      it "returns the response body" do
        expect(@crawler.next).to eq 'response body'
      end
    end # with queue

    context "with 301 response" do
      before do
        stub_request(:get, uri).
          to_return status: 301, body: '',
          headers: {'location' => "#{uri}/new-location"}
        @crawler = SiteMapper::Crawler.new
        @crawler.queue uri
      end

      it "creates a link from the location header" do
        expected = "<a href=\"#{uri}/new-location\">redirect</a>"
        expect(@crawler.next).to eq expected
      end
    end # with 301 response

    context "with 302 response" do
      before do
        stub_request(:get, uri).
          to_return status: 302, body: '',
          headers: {'location' => "#{uri}/new-location"}
        @crawler = SiteMapper::Crawler.new
        @crawler.queue uri
      end

      it "creates a link from the location header" do
        expected = "<a href=\"#{uri}/new-location\">redirect</a>"
        expect(@crawler.next).to eq expected
      end
    end # with 302 response
  end # .next
end
