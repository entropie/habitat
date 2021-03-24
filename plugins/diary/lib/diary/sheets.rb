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
      Sheets.new(@user).push(*dup.sort_by{|s| s.updated_at }.reverse)
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

  class DMedia
    attr_accessor :sheet
    attr_accessor :user
    attr_accessor :filename

    def initialize(sheet, filename)
      @filename = filename
      @sheet = sheet
    end

    def http_path
      @sheet.http_path(filename)
    end

    def virtual_path
      @sheet.virtual_path(filename)
    end

    def path
      @sheet.data_dir(filename)
    end

    # def to_html
    #   '<img src="%s" />' % http_path
    # end

    def to_html
      '<span data-filename="%s" data-url="%s">%s</span>' % [filename, http_path, "<img src='#{http_path}'/>"]
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

    def uploads
      files = Dir.glob("%s*.*" % File.join(data_dir, "/"))
      files.map{|f| DMedia.new(self, File.basename(f))}
    end

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
        if respond_to?("#{attribute}=")
          instance_variable_set("@#{attribute}", value)
        else
          warn "#{attribute} ignored"
        end
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
      File.join(::File.dirname(virtual_path), "%s.markdown" % id)
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

    def allowed_directory?(path)
      allowed_directories = [Habitat.quart.media_path("diary")]
      full_path = File.expand_path(path)
      allowed_directories.any? { |dir| dir == full_path[0..dir.size-1] }
    end

    def virtual_path(*args)
      wu = Habitat.adapter(:diary).with_user(user)
      ret = wu.user_path("sheets", wu.time_to_path(created_at), id, *args)
      ret
    end

    def virtual_file(*args)
      datepath = Habitat.adapter(:diary).with_user(user).time_to_path(created_at)
      ext = Database::Adapter::File::SHEET_EXTENSION
      virtual_path(args) + ext
    end

    def http_path(*args)
      wu = Habitat.adapter(:diary).with_user(user)
      File.join("/d/data/sheet", user.id, id, *args)
    end

    def relative_data_dir(*args)
      virtual_path(*args)
    end

    def data_dir(*args)
      ret = Habitat.quart.media_path(relative_data_dir(args))
      allowed_directory?(ret) and ret or raise "#{ret} not allowed"
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
