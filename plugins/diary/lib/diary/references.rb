require "nokogiri"

module Diary
  
  class References

    attr_accessor :sheet

    def self.adapater
      Diary::Database.with_adapter.new(Habitat.quart.media_path)
    end

    def self.normalize_key(k)
      k.to_s.downcase
    end

    def initialize(sheet)
      @sheet = sheet
    end

    def html
      @html ||= Nokogiri::HTML.fragment(@sheet.content)
    end

    def sheets
      @sheets ||= References.adapater.with_user(@sheet.user) do |adapter|
        adapter.sheets
      end
    end

    def reference_sheets
      @reference_sheets = sheets.map{|s| References.new(s) }
    end

    def find_links_by_reference(ref)
      reference_sheets.select { |r|
        r.keywords.include?(ref) and r.sheet.id != @sheet.id
      }.map{|r| r.sheet.id }
    end

    def words
      html.xpath("//text()").to_s.split
    end

    def keywords
      html.css("i").map do |ref|
        k = References.normalize_key(ref.content)
      end
    end

    def references
      refs = {}
      html.css("i").each do |ref|
        k = References.normalize_key(ref.content)
        refs[k] ||= []
        refs[k].push(*find_links_by_reference(k))
        refs[k].uniq!
      end
      refs
    end

  end 
end


