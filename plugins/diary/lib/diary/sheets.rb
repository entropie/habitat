module Diary
  class Sheets < Array

    attr_accessor :user

    def initialize(u)
      @user = u
      super()
    end

    def [](pid)
      result = dup.select{|sheet| sheet == pid }
      result.shift if result.size == 1
    end

    def by_last_edited
      Sheets.new(@user).push(*dup.sort_by{|s| s.updated_at })
    end

    def include?(other_or_id)
      tid = other_or_id.kind_of?(Sheet) ? other_or_id.id : other_or_id
      dup.reject{|s| s.id != tid}.size == 1
    end

    def by_reference_sorted(rfrnc)
      ref = References.normalize_key(rfrnc)
      by_refs = by_reference(rfrnc).sort_by{|r| r.title == ref ? 0 : 1}
      ret = Sheets.new(user)
      return [] if by_refs.empty?
      if by_refs.first.title == ref
        ret.push(by_refs.shift)
      end
      ret.push(*by_refs.sort_by{|br| br.title })
      ret
    end

    def by_reference(rfrnc)
      ref = References.normalize_key(rfrnc)
      select{|s| s.references.include?(ref) }
    end
  end

  class Sheet
    Attributes = {
      :created_at  => Time,
      :updated_at  => Time,
      :user_id     => String
    }
 
    OptionalAttributes = [:title]

    attr_accessor :user
    attr_accessor :id
    attr_accessor :title
    attr_accessor :preview
    attr_accessor :content
    attr_accessor :file

    attr_accessor *Attributes.keys

    def initialize(content = nil)
      @content = content
    end

    def title
      @title.to_s.size == 0 ? id : @title
    end

    def ==(pidorsheet)
      if pidorsheet.kind_of?(Integer)
        id == pidorsheet
      elsif pidorsheet.kind_of?(Sheet)
        id == pidorsheet.id
      end
    end

    def =~(obj)
      if obj.kind_of?(String)
        title == obj or @id == obj
      else
        false
      end
    end

    def user
      @user ||= Habitat.adapter(:user).by_id(@user_id)
    end

    def populate(param_hash)
      param_hash.each do |attribute, value|
        instance_variable_set("@#{attribute}", value)
      end
      self
    end

    def valid?
      missing = []
      Attributes.each do |attribute, attribute_type|
        next if OptionalAttributes.include?(attribute)

        if not var = instance_variable_get("@#{attribute}")
          missing << attribute
        elsif not var.kind_of?(attribute_type)
          missing << attribute
        else # pass
        end
      end
      not missing.any?
    end

    def references
      @references ||= References.new(self)
    end

    def markdown_file
      File.join(::File.dirname(virtual_file), "%s.markdown" % id)
    end

    def markdown_file=(obj)
      markdown_file = obj
    end

    def content
      @content ||= File.readlines(Habitat.adapter(:diary).realpath(markdown_file)).join
    end

    def file
      virtual_file
    end

    def virtual_file(*args)
      datepath = Habitat.adapter(:diary).with_user(user).time_to_path(created_at)
      ext = Database::Adapter::File::SHEET_EXTENSION
      up = Habitat.adapter(:diary).with_user(user).user_path("sheets", datepath, "%s%s" % [id, ext])
    end
    
    def to_hash
      r = {
        :content => content,
        :created_at => @created_at.rfc2822,
        :updated_at => @updated_at.rfc2822,
        :user_id => @user_id,
        :id => @id,
        :references => references.resolve.map{|r| r.id },
        :file => file
      }
      r.merge!(:title => @title) if @title
      r
    end

    def to_json
      to_hash.to_json
    end

    def domid
      "sheet-#{id[0..10]}" rescue "sheet-noid"
    end

  end

end
