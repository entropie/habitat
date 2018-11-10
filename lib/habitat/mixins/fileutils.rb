require "fileutils"

module Habitat::Mixins
  module FU
    extend FileUtils
    include FileUtils

    VERBOSE = false

    def mkdir_p(f, *args)
      log(:fs, "mkdir: #{f}")
      FileUtils.mkdir_p(f, :verbose => VERBOSE)
    end

    def cp(s, t)
      log(:fs, "cp: #{s} => #{t}")
      FileUtils.cp_r(s, t, :verbose => VERBOSE)
    end

    def rm_rf(fod)
      log(:fs, "rm -rf: #{fod}")
      FileUtils.rm_rf(fod)
    end

    def dirname(s)
      File.dirname(s)
    end

    def overwrite(file, cnts)
      cnts = cnts.to_s
      r=File.open(file, "w+") do |fp|
        fp.puts(cnts)
      end
      log :fs, "overwritten: #{file} #{r}"
    end

    def write(file, cnts)
      cnts = cnts.to_s
      r=File.open(file, "w+") do |fp|
        fp.puts(cnts)
      end
      log :fs, "write: #{file} #{r}"
    end

    def log(*args)
      super(*args)
    rescue
      pp args
    end
    
    
  end
end

