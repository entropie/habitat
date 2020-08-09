
module Blog
  module BackendModuleInfo

    class Info
      def self.modules
        @modules ||= []
      end
      
      def self.inherited(o)
        modules << o
      end

      def initialize(post)
        @post = post
      end

      def ident
        self.class.to_s.split("::").last.downcase.gsub(/info$/, "")
      end

      def to_html
        "<div class='post-info mod#{ident} text-ellipsis'><strong>#{ident}</strong> <span>%s</span></div>"
      end

      def plugin_activated?(plug)
        Habitat.quart.plugins.activated?(plug)
      end
    end

    class UserInfo < Info
      def user
        @user ||= Habitat.adapter(:user).by_id(@post.user_id)
      end
      
      def to_html
        if Habitat.quart.plugins.enabled?(:user)
          super % user.name
        else
          ""
        end
      end
    end


    class VGWortInfo < Info

      def post
        @post.with_plugin(VGWort)
      end
      
      def to_html
        ret = ""
        return "" unless Habitat.quart.plugins.enabled?(:vgwort)
        
        if post.vgwort.id_attached?
          ret = "#{post.vgwort.code}"
        else
          ret = "<span class='text-warning'>unset</span>"
        end
        super % ret
      end
    end


    class LanguagesInfo < Info

      def to_html
        langs = @post.languages
        return "" if langs.empty?
        super % langs.map {|l| "<a href='#{Blog.routes.post_path(@post.slug, l)}'>#{l}</a>"}
      end

    end
    
    class TemplateInfo < Info
      def to_html
        template = @post.template
        if template
          super % @post.template
        end
      end
    end

  end
end
