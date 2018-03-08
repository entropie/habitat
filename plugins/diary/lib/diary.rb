require_relative "diary/diary"
require_relative "diary/snippets"
require_relative "diary/renderer"
require_relative "diary/database"
require_relative "diary/snippets"
require_relative "diary/sheets"
#Diary.db

%w"controllers views representers".each do |parent_dir|
  target_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../", parent_dir)
  Dir.glob("%s/**/*.rb" % target_dir).each do |tf|
    begin
      Habitat._require tf
    # rescue
    #   p $!
    end
  end
end
