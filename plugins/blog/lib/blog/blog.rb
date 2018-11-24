# coding: utf-8
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require_relative "database"
require_relative "images"
require_relative "post"
require_relative "filter"
require_relative "templates"


module Blog

  DEFAULT_ADAPTER = :File

  TEMPLATE_PATH = File.join(File.dirname(__FILE__), "../../templates")

  def self.template_path
    @template_path
  end

  def self.template_path=(obj)
    @template_path = obj
  end

  module BlogControllerMethods
    def blog(*args, &blk)
      adapter(:blog).with_user(session_user, &blk)
    end
  end

  module BlogViewMethods
    
    def blog_author(post)
      adapter(:user).by_id(post.user_id)
    end

    def active_link(href, text, opts = {})
      path = locals[:params].env["REQUEST_PATH"]

      path.gsub!(/\/edit$/, "")

      add_content = ""

      if icon = opts[:icon]
        add_content << "<span class='glyphicon glyphicon-#{icon}'></span>"
      end
      clz = path == href ? "active" : ""

      ret = "<a href='%s' class='%s'>%s</a>" % [href, "#{clz} #{opts[:class] || "alink"}", text + add_content]
      raw(ret)
    end
  end

end

if Habitat.quart
  Habitat.add_adapter(:blog, Blog::Database.with_adapter.new(Habitat.quart.media_path))  
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
