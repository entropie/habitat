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

  module BlogControllerMethods
    def blog(*args, &blk)
      adapter(:blog).with_user(session_user, &blk)
    end
  end

  module BlogViewMethods
    def active_link_li(href, text, opts = {})
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

p Blog::TEMPLATE_PATH
# Blogs = Blog
=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
