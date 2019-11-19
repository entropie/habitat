require_relative "suite/helper"
require "minitest"

module Habitat

  module Tests

    module Suites

      class TestRunner
        attr_accessor :ident, :file, :environment
        def initialize(ident, file, environment)
          @ident, @file, @environment = ident, file, environment
          instance_eval(&environment) if environment
        end

        def run
          Habitat.log :info, "running suite [#{ident}] for #{Habitat.S(file)}"
          Habitat.log :info, "#{ident}:prepare"
          prepare!
          # -r 'minitest/autorun'
          puts %x"ruby  #{file}"
          Habitat.log :info, "#{ident}:teardown"
          teardown!
        end

        def prepare!

        end
        def teardown!
          Habitat.log :info, "nothing to teardown"
        end
      end
      
      class TestSuite

        attr_accessor :test_only
        
        def log(arg)
          Habitat.log(:debug, arg)
        end

        def initialize(path)
          @path = path
          @files = []
        end

        def self.environments
          (@environments ||= {})
        end

        def self.environment(to, &blk)
          TestSuite.environments[to] = blk
        end

        def environment(ident)
          TestSuite.environments[ident]
        end
        
        def run_test_for(file)
          ident = File.basename(file).split(".").first.to_sym
          load(file)
          TestRunner.new(ident, file, environment(ident)).run
        end

        def run_tests
          to_test = @files.dup

          if @test_only
            log "TEST_ONLY is provided; any non matching tests are discarded: TEST_ONLY='#{@test_only}'"
            to_test.delete_if{|f| File.basename(f).split(".").first != @test_only }
          end
          to_test.each do |file|
            run_test_for file
          end
          self
        end

        def self.run_test(test = nil)
          ret = new(Habitat::Source.join(self::PATH))
          ret.test_only = test if test
          ret.load_environment!
          ret.run_tests
        end


        def load_environment!
          log "loading test environment: #{self.class}"
          Dir["%s/*/test/*.rb" % @path].each do |file|
            log "  loading: #{Habitat.S(file)}"
            @files << file
          end
        end

      end

      class PluginsTestSuite < TestSuite
        PATH = "plugins"
      end

      def self.suite_for(obj)
        Suites.const_get(("%sTestSuite" % [obj.to_s.capitalize]).to_sym)
      end
    end
    
    def self.[](obj)
      Suites.suite_for(obj)
    end

  end
  
end
