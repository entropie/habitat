# coding: utf-8
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require_relative "database"
require_relative "images"
require_relative "post"
require_relative "module_info"
require_relative "filter"
require_relative "templates"


module Blog

  DEFAULT_ADAPTER = :File

  TEMPLATE_PATH = File.join(File.dirname(__FILE__), "../../templates")


  def self.template_path(*args)
    File.join(@template_path, *args)
  end

  def self.template_path=(obj)
    @template_path = obj
  end

  module BlogControllerMethods

    def blog(*args, &blk)
      adapter(:blog).with_user(session_user, &blk)
    end

    def posts_sorted(*args, sort_by: -> (post) { post.created_at }, &blk)
      blog.posts(*args, blk).sort_by(&sort_by).reverse
    end

  end



  module BlogViewMethods
    def blog_author(post)
      adapter(:user).by_id(post.user_id)
    end


    def backend_module_info(post)
      quart = Habitat.quart
      ret = []

      BackendModuleInfo::Info.modules.each do |infomod|
        clz = infomod.new(post)
        ret << clz.to_html.to_s
      end

      _raw ret.join
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
