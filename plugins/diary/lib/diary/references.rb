require "nokogiri"

module Diary
  
  class References

    attr_accessor :sheet

    def self.adapter
      @adapter = Habitat.adapter(:diary)
    end

    def self.normalize_key(k)
      k.to_s.downcase
    end

    def initialize(sheet)
      @sheet = sheet
    end

    # def html
    #   @html ||= Nokogiri::HTML.fragment(@sheet.content)
    # end

    def sheets
      @sheets ||= References.adapter.with_user(@sheet.user) do |adapter|
        adapter.sheets
      end
    end

    def resolve
      @references = sheets.select{|s| referenced_by?(s) }
    end

    def referenced_by?(osheet)
      #p sheet, osheet
      sheet != osheet && osheet.references.keywords.include?(sheet.title)
    end
    
    def reference_sheets
      @reference_sheets = sheets.map{|s| References.new(s) }
    end

    def each(&blk)
      resolve.each(&blk)
    end

    def find_links_by_reference(ref)
      reference_sheets.select { |r|
        r.references.include?(ref) # and r.sheet.id != @sheet.id
      }.map{|r| r.sheet.id }
    end

    def words
      html.xpath("//text()").to_s.split
    end

    def keywords
      @keywords = sheet.content.scan(/#(\w+)[ \s]?/).flatten.map{|kw| References.normalize_key(kw)}
    end

    def references
      @references
    end

    # def keywords
    #   html.css("a").map do |ref|
    #     key = ref.attr("href")
    #     next if key =~ /^https?.*/
    #     k = References.normalize_key(key)
    #     k
    #   end
    # end

    # def references
    #   refs = {}
    #   html.css("a").each do |ref|
    #     k = References.normalize_key(ref.content)
    #     refs[k] ||= []
    #     refs[k].push(*find_links_by_reference(k))
    #     refs[k].uniq!
    #   end
    #   refs
    # end

  end 
end


