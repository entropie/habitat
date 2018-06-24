# coding: utf-8

require_relative "../views/application_layout.rb"

%w"controllers views".each do |parent_dir|
  target_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../", parent_dir)
  Dir.entries(target_dir).select{|gdir| gdir !~ /^\./ }.each do |gdir|
    Dir.glob("%s/%s/*.rb" % [target_dir, gdir]).each do |tf|
      Habitat._require tf
    end
    
  end
end



