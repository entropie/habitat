require_relative "tumblog/tumblog"

%w"controllers".each do |parent_dir|
  target_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../", parent_dir)
  Dir.glob("%s/**/*.rb" % target_dir).each do |tf|
    begin
      Habitat._require tf

    # rescue
    #   p $!
    end
  end
end


