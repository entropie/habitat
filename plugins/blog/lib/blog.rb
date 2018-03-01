require_relative "blog/blog"

Blog.db

%w"controllers views representers".each do |parent_dir|
  target_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../", parent_dir)
  Dir.glob("%s/**/*.rb" % target_dir).each do |tf|
    begin
      Habitat.require tf
    rescue
      p $!
    end
  end
end

