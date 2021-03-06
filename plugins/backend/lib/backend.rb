# coding: utf-8

require_relative "../views/application_layout.rb"
%w"controllers views".each do |parent_dir|
  target_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../", parent_dir)
  Dir.entries(target_dir).select{|gdir| gdir !~ /^\./ }.each do |gdir|

    if File.symlink?(File.join(target_dir, gdir)) and not Habitat.quart.plugins.enabled?(gdir)
      next
    end
    
    Dir.glob("%s/%s/*.rb" % [target_dir, gdir]).each do |tf|
      begin
        Habitat._require tf
      rescue
        p $!
      end
    end
    
  end
end



