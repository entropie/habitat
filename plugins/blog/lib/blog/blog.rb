# coding: utf-8
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require_relative "database"
require_relative "post"
require_relative "filter"
require_relative "templates"

module Blog

  DEFAULT_ADAPTER = :File


  # Plugins.set_plugin_defaults_for(self, {
  #                                   :template_path      =>    "blog/styles",
  #                                   :attachment_path    =>    "blog/attachments",
  #                                   :http_attachment_path =>  "/assets/blog/attachments",
  #                                   :blog_controller    =>    proc { BlogController },
  #                                   :admin_controller   =>    proc { AdminController },
  #                                   :resize_methods     =>    [:thumbnail, :medium, :sidebar, :big, :panorama, :blurred]
  #                                 })


  def self.to_slug(str)
    str.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

  def posts(logged_in = false)
  end

  def random_post
    posts.sort_by{rand}.first
  end

  def find_by(arg, logged_in = false)
    posts(logged_in).select{ |pst| pst.post.slug == arg }.first.post
  rescue
    nil
  end

  def find_by_pid(rpid, logged_in = false)
    posts(logged_in).select{ |pst| pst.post.pid == rpid }.first.post
  rescue
    nil
  end


  def find_by_tags(logged_in, *arg)
    posts(logged_in).select{ |pst| pst.post.tags.any?{|t| arg.include?(t) } }.map{|p| p.post }
  end


  # class Post

  #   attr_accessor :file, :title, :content, :metadata

  #   def attachment_path(*args)
  #     Habitat.quart.media_path("attachments", slug, *args)
  #   end

  #   def vitrine_image_file
  #     metadata.image
  #   end

  #   def image=(imagepath)
  #     dig = Digest::SHA1.file(imagepath).to_s
  #     target = "%s%s" % [dig, File.extname(imagepath).downcase]
  #     target_path = attachment_path(dig)
  #     FileUtils.mkdir_p(attachment_path(dig))

  #     FileUtils.cp(imagepath, File.join(target_path, target), :verbose => true)
        
  #     ts = Blogs.config[:resize_methods]
  #     Helper::ImageResize::ImageResizeFacility.new(:path => File.join(target_path)) {
  #       resize(File.join(target_path, target))
  #     }.start(*ts)
  #     metadata.image = target
  #     metadata.update!
  #   end

  #   def slug
  #     @slug ||= Blogs.to_slug(title)
  #   end

  #   def http_attachment_path(*args)
  #     File.join(File.join("/attachments", slug, *args.map(&:to_s)))
  #   end

  #   def vitrine_image(version = "", default = "")
  #     ident = metadata.image.split(".").first
  #     http_attachment_path("vitrine", vitrine_image_file)
  #   end

  #   def intro(link = true)
  #     go_onlink = " <span style='color:silver'>[...]</span>&nbsp;<a href='#{url}'>weiterlesen</a>"
  #     str = Nokogiri::HTML(to_html).xpath("//p").first.text
  #     if link
  #       return str + go_onlink
  #     end
  #     str
  #   end

  #   def short_description(link = true)
  #     str = Nokogiri::HTML(to_html).xpath("//p").first.text
  #   end

  #   def publish!
  #     src = relative_path
  #     target = relative_path.gsub(/\/draft\//, "/posts/")
  #     FileUtils.mv(File.join(Queen::BEEHIVE.media_path(src)),
  #                  File.join(Queen::BEEHIVE.media_path, target), :verbose => true)
  #     metadata.filename = target
  #     metadata.publish!
  #     Database.reload!
  #     self
  #   end

  #   def unpublish!
  #     src = relative_path
  #     target = relative_path.gsub(/\/posts\//, "/draft/")
  #     FileUtils.mv(File.join(Queen::BEEHIVE.media_path(src)),
  #                  File.join(Queen::BEEHIVE.media_path, target), :verbose => true)
  #     metadata.filename = target
  #     metadata.unpublish!
  #     Database.reload!
  #     self
  #   end

  #   # FIXME: haha
  #   def relative_path
  #     "%s.markdown" % File.join("blog", (published? ? "posts" : "draft"), slug) 
  #   end

  #   def published?
  #     metadata.published?
  #   end

  #   def publish_or_unpublish
  #     if published? then unpublish! else publish! end
  #   end

  #   def image?
  #     metadata.image rescue nil
  #   end

  #   def edit_date
  #     metadata.edit_date
  #   end

  #   def in_group?
  #     not group.name.empty?
  #   end

  #   def template
  #     metadata.template
  #   end

  #   def template_path
  #     Blogs.template_path(template)
  #   end

  #   def image(which = "")
  #     vitrine_image(which)
  #   end

  #   def default_path
  #     Blogs.path
  #   end

  #   def initialize(file)
  #     @file = file
  #   end

  #   def ==(obj)
  #     obj.slug == slug
  #   end

  #   def group
  #     @group ||= Database.groups[metadata.group]
  #   end

  #   def title
  #     @title || metadata.title
  #   end

  #   def path
  #     Habitat.quart.media_path(metadata.filename)
  #   end

  #   def content
  #     @content ||= File.readlines(path).join
  #   end

  #   def to_html
  #     Filter.apply(:html, self)
  #   end

  #   def pid
  #     @pid ||= Digest::SHA256.hexdigest(slug)
  #   end

  #   def to_hash
  #     {
  #       :content => content,
  #       :id      => pid,
  #       :author  => metadata.author.to_json,
  #       :tags    => tags,
  #       :date    => date,
  #       :edit_date => edit_date,
  #       :draft   => draft?,
  #       :group   => group.to_hash,
  #       :image   => metadata.image,
  #       :attachment_path => http_attachment_path,
  #       :slug    => slug,
  #       :title   => title
  #     }
  #   end

  #   def html_title(active = false, logged_in = true)
  #     clshsh = ["post-title"]
  #     clshsh << "active" if active
  #     clshsh << "draft" if draft? and logged_in
  #     %Q'<a href="#{url}" class="#{clshsh.join(" ")}">#{title}</a>'
  #   end

  #   def url
  #     File.join("/post", slug)
  #   end

  #   def edit_url
  #     Blogs.config[:admin_controller].call.r(:blog, slug)
  #   end

  #   def author
  #     metadata.author.to_html
  #   end

  #   def date
  #     ret = if published?
  #             metadata.published_date
  #           else
  #             metadata.date
  #           end
  #     ret
  #   end

  #   def basename
  #     "%s.markdown" % Blogs.to_slug(title)
  #   end

  #   def tags
  #     metadata.tags
  #   end

  #   def update!
  #     metadata.update!
  #   end

  #   def draft?
  #     not metadata.published?
  #   end

  #   def publish_or_unpublish_url
  #     Blogs.config[:blog_controller].call.r(:publish_or_unpublish, slug)
  #   end

  #   def upload_url
  #     Blogs.config[:admin_controller].call.r(:upload, :postslug => slug)
  #   end

  #   def delete
  #     [attachment_path, path, metadata.md_filename].each do |ftd|
  #       FileUtils.rm_rf(ftd, :verbose => true)
  #     end
  #     Database.reload!
  #     self
  #   end

  #   def page_title
  #     "Vereinstagebuch &mdash; %s" % title
  #   end


  # end

  # class Draft < Post
  #   def publish!
  #     log :info, "publishing #{title}"
  #     metadata.publish!
  #     update!
  #   end
  # end

  # class NewPost < Draft

  #   def title
  #     @params["title"]
  #   end

  #   def content
  #     @params["content"]
  #   end

  #   def default_path
  #     File.join(super, "draft")
  #   end

  #   def initialize(request)
  #     @params = request.params
  #     @request = request
  #   end

  #   def write(u = Contributors::Anna)
  #     if title.nil? or title.empty?
  #       raise "no title"
  #     elsif content.nil? or content.empty?
  #       raise "no content"
  #     end
  #     bn = File.join(default_path, basename)

  #     self.metadata = Metadata.new(bn, title)

  #     metadata.load_if_exist!

  #     # FIXME:
  #     self.metadata.author ||= u

  #     metadata.template  = @params["template"]
  #     metadata.group     = @params["group"]

  #     tags = @request[:tags].to_s.split(",")

  #     metadata.add_tags(*tags)

  #     write_to(path, "w+"){ |fp|
  #       fp.write(content)
  #       Filter.clear!(self)
  #       metadata.write
  #     }
  #     Database.reload!
  #     self
  #   end

  # end

  # module Database
  #   def self.read_for(&blk)

  #     ret = contents
  #     ret.sort_by!{ |pst| pst.post.date }.reverse!
  #     ret.each(&blk) if block_given?
  #     ret
  #   end

  #   def self.groups
  #     @groups = contents.select{|md| not md.group.strip.empty? }.inject(Groups.new) { |m, md| 
  #       m[md.group] << md.post
  #       m
  #     }
  #     @groups
  #   end

  #   def self.glob(p = Habitat.quart.media_path(base_path + "/*.yaml"))
  #     Dir.glob(p)
  #   end

  #   def self.clear!
  #     @__content__ = []
  #     @groups      = []
  #   end

  #   def self.reload!
  #     clear!
  #     DB.clear
  #     contents
  #   end

  #   def self.contents
  #     return to_a if to_a and not to_a.empty?
  #     clear!
  #     Habitat.log :info, "reading posts in ... #{Habitat.quart.media_path(base_path + "/*.yaml")}"
  #     glob.each do |yml|
  #       begin
  #         #Habitat.log :info, "  loading #{File.basename(yml)}"
  #         self << YAML::load_file(yml)
  #       # rescue ArgumentError
  #       #   error "  failed to load #{File.basename(yml)} '#{$!}'"
  #       end
  #     end
  #     to_a
  #   end

  #   def self.to_a
  #     @__content__
  #   end

  #   def self.<<(obj)
  #     (@__content__ ||= []) << obj
  #   end

  #   def self.base_path
  #     File.join("blog", "metadata")
  #   end
  # end

  # class Metadata

  #   FIELDS = [:filename, :title, :date, :author, :published_date,
  #             :tags, :edit_date, :group, :language, :image, :template, :published]

  #   attr_accessor *FIELDS

  #   def initialize(*args)
  #     FIELDS.each do |f|
  #       instance_variable_set("@#{f}", args[FIELDS.index(f)])
  #     end
  #   end

  #   def load_if_exist!
  #     if @author.nil? and File.exist?(md_filename)
  #       fc = YAML::load_file(md_filename)
  #       FIELDS.each do |f|
  #         instance_variable_set("@#{f}", fc.send(f))
  #       end
  #     end
  #   end

  #   def template
  #     @template || "default"
  #   end

  #   def template=(tmpl)
  #     @template = tmpl
  #   end

  #   def group=(grp)
  #     @group = grp
  #   end

  #   def self.normalize_tags(ts)
  #     ts.map{ |t| t.strip.downcase }.uniq
  #   end

  #   def language
  #     @language ||= "de"
  #   end

  #   def post
  #     @post = Blogs[self]
  #   end

  #   def update!
  #     self.edit_date = Time.now
  #     write
  #   end

  #   def relative_path
  #     File.join("blog", "metadata", Blogs.to_slug(title)) + ".yaml"
  #   end

  #   def add_tags(*inputtags)
  #     @tags = self.class.normalize_tags(inputtags)
  #   end

  #   def published
  #     @published
  #   end

  #   def published?
  #     filename =~ /\/posts\//
  #   end

  #   def publish!
  #     self.published_date = Time.now
  #     write
  #   end

  #   def unpublish!
  #     self.published_date = nil
  #     write
  #   end

  #   def md_filename
  #     Habitat.quart.media_path(relative_path)
  #   end

  #   def write
  #     t = Time.now
  #     @date ||= t
  #     @edit_date = t
  #     language # to make sure the variable is set for yaml
  #     write_to(md_filename, "w+") { |fp|
  #       @db = nil
  #       t = self
  #       t.remove_instance_variable(:@db)
  #       fp.write(t.to_yaml)
  #     }
  #   end
  # end

end

# Blogs = Blog
=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
