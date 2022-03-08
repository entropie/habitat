require "builder"

module Rss
  def to_xml(&blk)
    xml = Builder::XmlMarkup.new(:indent => 1)
    xml.rss :version => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
      xml.stylesheet(:type => "text/css", :href => "#{C[:host]}/assets/screen-app.css")
      xml.channel do
        xml.title C[:title]
        xml.description(C[:description], "type" => "html")
        xml.language "en-en"
        xml.generator "Plaby"
        xml.link C[:host]
        xml.pubDate(Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")) #Time.now.rfc2822
        xml.managingEditor "mictro@gmail.com"
        xml.webMaster "mictro@gmail.com"
        yield xml
      end
    end
    xml.target!
  end
end

module Feed::Controllers::Feed
  class Index
    include Api::Action
    include Rss

    def call(params)
      self.status = 200
      res = FileCache.cached_or_fresh(:feed, force_when: lambda{ |o| (Time.now - ::File.mtime(o)) > FileCache::DEFAULT_CACHE_TIMER}) do
        to_xml do |xml|
          blog.posts.sort_by {|p| p.created_at }.reverse.first(10).each do |post|
            begin
              post_to_xml(xml, post)
            rescue
            end
          end
        end

      end
      self.body = res
    end
  end
end
