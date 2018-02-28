require_relative "blog/blog"

Blog.db

%w"controllers views".each do |parent_dir|
  target_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../", parent_dir)
  Dir.glob("%s/**/*.rb" % target_dir).each do |tf|
    Habitat.log :debug, "require #{Habitat.S(tf)}"
    require tf
  end
end

