module Rss
  def to_xml(&blk)
    xml = Builder::XmlMarkup.new(:indent => 1)
    xml.rss :version => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
      xml.stylesheet(:type => "text/css", :href => "#{C[:host]}/assets/screen.css")
      xml.channel do
        xml.title C[:title]
        xml.description C[:description]
        xml.language "en-en"
        xml.generator "Plaby"
        xml.link "http://#{C[:host]}#{routes.posts_path}"
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
      self.body = to_xml do |xml|
        blog.posts.each do |post|
          begin
            post_to_xml(xml, post)
          rescue
          end
        end
      end
    end
  end
end
