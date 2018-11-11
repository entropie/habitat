# coding: utf-8
module Felle

  DEFAULT_ADAPTER = :File

  Male   = 0
  Female = 1

  STATES = {
    0 => "suchen",
    9 => "gefunden",
    3 => "ausserhalb",
    4 => "vorbehalt",
    7 => "verstorben",
    8 => "system"
  }

  STATES_TRANSLATED = {
    0 => "Auf der suche",
    9 => "Schon angekommen",
    3 => "Vereinsfremde",
    4 => "Unter Vorbehalt",
    8 => "System",
    7 => "Regenbogenbrücke",
  }


  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

        include Habitat::Mixins::FU

        def initialize(path)
          @path = path
        end

        def path(*args)
          ::File.join(@path, *args)
        end

        def fellclass(type)
          Felle.const_get(type.to_s.capitalize.capitalize)
        end

        def setup
          @setup = true
          log :debug, "setting up adapter directory #{path}"
          FileUtils.mkdir_p(path)
          @setup
        end

        def repository_path(*args)
          ::File.join(::File.realpath(path), "felle", *args)
        rescue Errno::ENOENT
          warn "does not exist: #{path("blog")}"
          path("felle", *args)
        end

        def exist?(fell)
          #::File.exist?(post_filename(post))
        end

        def datadir(*args)
          ::File.expand_path(repository_path("../data", *args))
        end

        def fell_files
          toglob = repository_path + "/**/*.yaml"
          Dir.glob(toglob).map {|ff|
            YAML::load_file(ff)
          }
        end

        def select(obj, env = nil)
        end

        def exist?(obj)
        end

        def felle
        end

        def load_file(yamlfile)
        end

        def find(slug)
          res = fell_files.select {|ff| ff.slug == slug }
          res.size == 1 and res.first
        end

        def create(ident, attributes: {}, type: :Hund, state: 0, gender:, birthday:, origin:, breed: "crossbreed")
          clz = fellclass(type).new(ident) #, attributes: attributes)
          clz.adapter = self
          clz.attributes = attributes

          clz.gender   = gender
          clz.birthday = birthday
          clz.origin   = origin
          clz.breed    = breed
          clz.state    = state

          clz.root = clz.root
          clz.datadir = clz.datadir
          clz.updated_at = Time.now
          clz
        end

        # def update_or_create(ident, param_hash)
        #   snippet = adapter_class(kind).new(ident).extend(SnippetCreater)
        #   store(snippet, content)
        # end

        def store(fell)
          log :info, "felle:STORE:#{fell.slug}"
          
          content = fell.to_yaml

          file = fell.yaml_file
          FileUtils.mkdir_p(::File.dirname(file), :verbose => true) 
          write(file, content)
        end

        def destroy(snippet)
          # log :info, "snippet:REMOVE:#{snippet.ident}"
          # rm(repository_path(snippet.filename), :verbose => true)
        end
      end

    end

  end

end
