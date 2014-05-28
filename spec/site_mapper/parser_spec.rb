require 'spec_helper'

describe SiteMapper::Parser do
  let (:uri) { 'http://digitalocean.com' }

  describe ".initialize" do
    it "creates a new parser for an html document" do
      html = '<!doctype html><title></title>'
      parser = SiteMapper::Parser.new uri, html
      expect(parser).to be_kind_of SiteMapper::Parser
    end
  end # .initialize

  describe ".a_tag_urls" do
    it "returns array of urls" do
      @parser = SiteMapper::Parser.new uri, fixture('anchors.html')
      expected = [
        'http://digitalocean.com/',
        'http://digitalocean.com/keep',
        'http://digitalocean.com/keep.zip'
      ]
      expect(@parser.a_tag_urls).to match_array expected
    end
  end # .a_tag_urls

  describe ".area_tag_urls" do
    it "returns array of urls" do
      html = fixture('parser-benchmark.html')
      parser = SiteMapper::Parser.new uri, html
      expect(parser.area_tag_urls).to match_array ["#{uri}/area-link.html"]
    end
  end # .area_tag_urls

  describe ".urls" do
    it "returns array of urls" do
      html = '<a href="/careers">careers</a>'
      parser = SiteMapper::Parser.new uri, html
      urls = parser.urls 'a', 'href'
      expect(urls.first).to eq "#{uri}/careers"
    end

    it "discards invalid urls" do
      html = '<a href="http:"></a>'
      parser = SiteMapper::Parser.new uri, html
      urls = parser.urls 'a', 'href'
      expect(urls.empty?).to eq true
    end

    it "escapes pipe | characters" do
      html = '<link href="css?family=Droid+Sans:400,700|Bitter:400,700,400">'
      parser = SiteMapper::Parser.new uri, html
      urls = parser.urls 'link', 'href'
      expect(urls.first).to include '|'
    end

    context "with partial url" do
      it "discards hash fragments" do
        html = '<a href="about#hash">hashy fresh</a>'
        parser = SiteMapper::Parser.new uri, html
        urls = parser.urls 'a', 'href'
        expect(urls.first).to eq "#{uri}/about"
      end
    end # with partial url

    context "with absolute url" do
      it "discards hash fragments" do
        html = "<a href=\"#{uri}/absolute#hashndash\">hashy fresh</a>"
        parser = SiteMapper::Parser.new uri, html
        urls = parser.urls 'a', 'href'
        expect(urls.first).to eq "#{uri}/absolute"
      end
    end # with absolute url

    it "excludes data uris" do
      html = '<a href="data:image/png;base64,iVBORw0K">bad</a>'
      parser = SiteMapper::Parser.new uri, html
      urls = parser.urls 'a', 'href'
      expect(urls.empty?).to eq true
    end

    it "excludes mailto uris" do
      html = '<a href="mailto:joey@spam.com">bad</a>'
      parser = SiteMapper::Parser.new uri, html
      urls = parser.urls 'a', 'href'
      expect(urls.empty?).to eq true
    end

    it "excludes inline javascript uris" do
      html = '<a href="javascript:alert(1)">bad</a>'
      parser = SiteMapper::Parser.new uri, html
      urls = parser.urls 'a', 'href'
      expect(urls.empty?).to eq true
    end
  end # .urls

  describe ".link_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<link href="css/main.css">'
      urls = parser.link_tag_urls
      expect(urls.first).to eq "#{uri}/css/main.css"
    end
  end # .link_tag_urls

  describe ".img_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<img src="image.png">'
      urls = parser.img_tag_urls
      expect(urls.first).to eq "#{uri}/image.png"
    end
  end # .img_tag_urls

  describe ".embed_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<embed src="demo.mov">'
      urls = parser.embed_tag_urls
      expect(urls.first).to eq "#{uri}/demo.mov"
    end
  end # .embed_tag_urls

  describe ".object_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<object data="thing.swf"></object>'
      urls = parser.object_tag_urls
      expect(urls.first).to eq "#{uri}/thing.swf"
    end
  end # .object_tag_urls

  describe ".param_tag_urls" do
    it "returns array of urls" do
      pending <<REASON
Edge case. Params can be urls but there is no valid html5 attribute to
identify the value as a url.
REASON
      fail
    end
  end # .param_tag_urls

  describe ".video_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<video src="video.ogg"></video>'
      urls = parser.video_tag_urls
      expect(urls.first).to eq "#{uri}/video.ogg"
    end
  end # .video_tag_urls

  describe ".track_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<track src="video.en.vtt">'
      urls = parser.track_tag_urls
      expect(urls.first).to eq "#{uri}/video.en.vtt"
    end
  end # .track_tag_urls

  describe ".audio_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<audio src="beep.wav"></audio>'
      urls = parser.audio_tag_urls
      expect(urls.first).to eq "#{uri}/beep.wav"
    end
  end # .audio_tag_urls

  describe ".source_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<source src="boop.wav">'
      urls = parser.source_tag_urls
      expect(urls.first).to eq "#{uri}/boop.wav"
    end
  end # .source_tag_urls

  describe ".script_tag_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, '<script src="main.js"></script>'
      urls = parser.script_tag_urls
      expect(urls.first).to eq "#{uri}/main.js"
    end
  end # .script_tag_urls

  describe ".asset_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, fixture('parser-benchmark.html')
      external_uri = 'http://external.url'
      expected = [
        "#{uri}/css/normalize.css",
        "#{uri}/images/logo.png",
        "#{uri}/assets/demo.mov",
        "#{uri}/assets/object.swf",
        "#{uri}/assets/video.ogg",
        "#{uri}/assets/video.en.vtt",
        "#{uri}/assets/audio.wav",
        "#{uri}/assets/source.wav",
        "#{uri}/js/index.js",
        "#{external_uri}/css/normalize.css",
        "#{external_uri}/images/logo.png",
        "#{external_uri}/assets/demo.mov",
        "#{external_uri}/assets/object.swf",
        "#{external_uri}/assets/video.ogg",
        "#{external_uri}/assets/video.en.vtt",
        "#{external_uri}/assets/audio.wav",
        "#{external_uri}/assets/source.wav",
        "#{external_uri}/js/index.js",
        "#{external_uri}/external.js"
      ]
      expect(parser.asset_urls).to match_array expected
    end
  end # .asset_urls

  describe ".link_urls" do
    it "returns array of urls" do
      parser = SiteMapper::Parser.new uri, fixture('parser-benchmark.html')
      expected = [
        "#{uri}/careers",
        "#{uri}/area-link.html",
        "#{uri}/about-us",
      ]
      expect(parser.link_urls).to match_array expected
    end
  end # .link_urls

  describe ".process" do
    it "returns link and asset urls" do
      html = fixture('parser-benchmark.html')
      external_uri = "http://external.url"
      expected = {
        link_urls: [
          "#{uri}/careers",
          "#{uri}/area-link.html",
          "#{uri}/about-us",
        ],
        asset_urls: [
          "#{uri}/css/normalize.css",
          "#{uri}/images/logo.png",
          "#{uri}/assets/demo.mov",
          "#{uri}/assets/object.swf",
          "#{uri}/assets/video.ogg",
          "#{uri}/assets/video.en.vtt",
          "#{uri}/assets/audio.wav",
          "#{uri}/assets/source.wav",
          "#{uri}/js/index.js",
          "#{external_uri}/css/normalize.css",
          "#{external_uri}/images/logo.png",
          "#{external_uri}/assets/demo.mov",
          "#{external_uri}/assets/object.swf",
          "#{external_uri}/assets/video.ogg",
          "#{external_uri}/assets/video.en.vtt",
          "#{external_uri}/assets/audio.wav",
          "#{external_uri}/assets/source.wav",
          "#{external_uri}/js/index.js",
          "#{external_uri}/external.js"
        ]
      }
      parser = SiteMapper::Parser.new uri, html
      expect(parser.link_urls).to match_array expected[:link_urls]
      expect(parser.asset_urls).to match_array expected[:asset_urls]
    end

    it "parses urls from svg elements" do
      pending "Skip this edge case for now"
      fail
    end
  end # .process
end # SiteMapper::Parser
