# coding: utf-8

module Diary

  module Database

    class DataBaseError < StandardError; end
    class NotImplemented < DataBaseError; end
    class NotAuthorized < DataBaseError; end
    class NoUserContext < NotAuthorized; end      


    
    def log(w, msg)
      if Object.constants.include?(:Habitat)
        Habitat.log(w, msg)
      else
        puts "DB> #{msg}"
      end
    end
    module_function :log

    def self.adapter
      @adapter ||= Diary::DEFAULT_ADAPTER
    end
    
    def self.adapter=(obj)
      @adapter = obj
    end

    def self.with_adapter(adpt = adapter)
      Adapter.const_get(adpt.to_s.capitalize.to_sym)
    end

    class Adapter

      include Database

      NOT_IMPLMENTED_MSG = "not implemented in parent class; use corresponding subclass instead".freeze

      attr_reader :user

      def setup
        raise NotImplemented, NOT_IMPLMENTED_MSG
      end

      def with_registered_user(user, &blk)
        raise NotImplemented, NOT_IMPLMENTED_MSG
      end
      
      def query(*_)
        raise NotImplemented, NOT_IMPLMENTED_MSG
      end

      def sheets
        raise NotImplemented, NOT_IMPLMENTED_MSG        
      end

      def sheet_class
        Sheet.new
      end

      def create_sheet(param_hash)
        unless (Sheet::Attributes.keys - param_hash.keys).empty?
          raise "wrong set of keys in #{param_hash}; valid keys are: "+
                "#{Sheets::Attributes.keys}"

        end
        sheet_class.populate(param_hash)
      end

      def without_user(&blk)
        bkup = @user; @user = nil
        yield self
        @user = bkup
      end
      
      class File < Adapter

        SHEET_EXTENSION = ".sheet.yaml".freeze
        
        include Habitat::Mixins::FU

        attr_reader :path

        module SheetFileExtension
          attr_accessor :file
        end

        def initialize(path)
          @path = path
          @user = nil
        end

        def sheet_class
          Sheet.new.extend(SheetFileExtension)
        end

        def path(*args)
          ::File.join(@path, *args)
        end

        def user_path(*args)
          raise NoUserContext, "trying to access no existing user directory: " unless @user
          ::File.join(::File.realpath(@user.diary_path("sheets")), @user.id.to_s, *args)
        end

        def current_sheet_path(*args)
          user_path(*Time.now.strftime("%Y/%m/").split("/"), *args)
        end

        def sheet_filename(sheet)
          current_sheet_path(sheet.id + SHEET_EXTENSION)
        end

        def setup
          @setup = true
          log :debug, "setting up adapter directory #{path}"
          mkdir_p(path)
          true
        end

        def setup?
          @setup
        end

        def with_user(user, &blk)
          @user, @sheets = user, nil
          ret = yield self
          @user, @sheets = nil, nil
          ret
        end

        def sheet_files(user = nil)
          raise NoUserContext, "cant read sheets without user" if user.nil? and @user.nil?
          Dir.glob(user_path + "/**/**/*" + SHEET_EXTENSION)
        end

        def sheets(user = nil, &blk)
          raise NoUserContext, "cant read sheets without user" if user.nil? and @user.nil?
          read_sheets = []
          sheet_files.each do |sfile|
            read_sheets << load_file(sfile)
          end
          ret = Sheets.new(user || @user).push(*read_sheets)
          if block_given?
            ret.each(&blk)
          end
          return ret
        end

        def load_file(sfile)
          YAML.load_file(sfile)
        end

        def create_sheet(content)
          now = Time.now
          hash = {
            :id         => Sheet.get_random_id,
            :content    => content,
            :created_at => now,
            :updated_at => now,
            :user_id    => @user.id
          }
          super(hash)
        end

        def store(sheet)
          raise "invalid sheet: #{PP.pp(sheet, '')}" unless sheet.valid?
          mkdir_p(user_path) unless ::File.exist?(user_path)

          unless sheet.file
            sheet.file = sheet_filename(sheet)
            mkdir_p(dirname(sheet.file))
          end

          write(sheet.file, YAML.dump(sheet))
          sheet
        end

        def update_sheet(sheet, param_hash)
          sheet = sheet.extend(SheetFileExtension)
          needs_update = false

          param_hash.each do |param, value|
            needs_update = true
            sheet.send("%s=" % [param.to_s], value)
          end

          if needs_update
            sheet.updated_at = Time.now
            store(sheet)
          end

        end
        
      end
    end
  end
end


