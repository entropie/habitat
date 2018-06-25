module Backend

  def self.q
    Habitat.quart
  end
  
  def self.backend_modules
    q.plugins.select {|plug| plug.backend? }.map do |plug|
      plug.identifier
    end
  end

  def self.submenu_template(bm)
    a = q.plugins.select {|plug| plug.backend? }.select{|plug|
      plug.identifier == bm
    }.first
    if tmplf = a.submenu_template(bm.to_s)
      return "%s/%s" % [bm.to_s, tmplf]
    end
    false
  end

  module BackendViewModule
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
    end

    class VGWortInfo < Info
      def post
        @post.with_plugin(VGWort)
      end
      
      def to_html
        ret = ""
        if post.vgwort.id_attached?
          ret = "#{post.vgwort.code}"
        else
          ret = "<span class='text-warning'>unset</span>"
        end
        super % ret
      end
    end

    class UserIfno < Info
      def user
        @user ||= Habitat.adapter(:user).by_id(@post.user_id)
      end
      
      def to_html
        super % user.name
      end
    end
    
    def module_info(post)
      quart = Habitat.quart
      ret = []

      Info.modules.each do |infomod|
        clz = infomod.new(post)
        ret << clz.to_html
      end

      _raw ret.join
    end    
  end

  
end
