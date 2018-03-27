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
  end

  class Sheet
    Attributes = {
      :content     => String,
      :created_at  => Time,
      :updated_at  => Time,
      :user_id     => Fixnum
    }
 
    OptionalAttributes = [:title]

    def self.get_random_id
      ary = [*'a'..'z', *'A'..'Z', *0..9].shuffle(random: SecureRandom.hex(23).to_i(16))
      enum = ary.permutation(32)
      enum.next.join
    end

    attr_accessor :user
    attr_accessor :id
    attr_accessor :title
    attr_accessor :preview

    attr_accessor *Attributes.keys

    def initialize(content = nil)
      @content = content
    end

    def ==(pid)
      id == pid
    end

    def user
      Users[@user_id]
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

    def to_hash
      r = {
        :content => @content,
        :created_at => @created_at.rfc2822,
        :updated_at => @updated_at.rfc2822,
        :user_id => @user_id,
        :id => @id,
        :references => references.references,
        :preview => @preview || ""
      }
      r.merge!(:title => @title) if @title
      r
    end

    def to_json
      to_hash.to_json
    end
  end

end
