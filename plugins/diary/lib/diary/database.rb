# coding: utf-8

module Diary

  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

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

        def adapter_class
          Sheet.new.extend(SheetFileExtension)
        end

        def path(*args)
          ::File.join(@path, *args)
        end

        def user_path(*args)
          raise NoUserContext, "trying to access user directory without valid user context" unless @user
          ::File.join(::File.realpath(path), "diary", @user.id.to_s, *args)
        rescue Errno::ENOENT
          warn "does not exist: #{path("diary")}"
          path("diary", @user.id.to_s, *args)
        end

        def current_sheet_path(*args)
          user_path("sheets", *Time.now.strftime("%Y/%m/").split("/"), *args)
        end

        def sheet_filename(sheet)
          current_sheet_path(sheet.id + SHEET_EXTENSION)
        end

        def setup
          @setup = true
          log :debug, "setting up adapter directory #{path}"
          mkdir_p(path)
          @setup
        end

        def setup?
          @setup and ::File.exist?(path)
        end

        def with_user(user, &blk)
          @user, @sheets = user, nil

          if block_given?
            ret = yield self
            @user, @sheets = nil, nil
          else
            return self
          end
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

        def find(phash)
          ret = Sheets.new(@user)
          sheets(@user).each{|s|
            candidate = s
            phash.each do |k,v|
              ret.push(candidate) if candidate.send(k) == v
            end
          }
          ret
        end

        def load_file(sfile)
          YAML.load_file(sfile)
        end

        def update_or_create(hash)
          sheet = nil
          if id = hash[:id]
            sheet = find(:id => id).first.extend(SheetFileExtension)
          end
          sheet = create(hash) unless sheet

          sheet.populate(hash)
          return sheet
        end

        def create(content)
          now = Time.now
          ncontent = content.kind_of?(String) ? content : content.delete(:content)
          hash = {
            :id         => Habitat::Database.get_random_id,
            :content    => ncontent,
            :created_at => now,
            :updated_at => now,
            :user_id    => @user.id
          }
          if content.kind_of?(Hash)
            hash.merge!(content)
          end
          
          super(hash)
        end

        def store(sheet)
          raise "invalid sheet: #{PP.pp(sheet, '')}" unless sheet.valid?
          mkdir_p(user_path) unless ::File.exist?(user_path)

          unless sheet.file
            sheet.file = sheet_filename(sheet)
            mkdir_p(dirname(sheet.file))
          end

          sheet.updated_at = Time.now
          write(sheet.file, YAML.dump(sheet))
          sheet
        end

        def upload(sheet, params)
          file = params[:tempfile]
          mkdir_p(sheet.data_dir)
          filename = Digest::SHA1.hexdigest(file.read) + ::File.extname(params[:filename])
          cp(file.path, sheet.data_dir(filename))
          filename
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


