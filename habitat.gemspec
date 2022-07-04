Gem::Specification.new do |s|
  s.name = "habitat"
  s.version = "0.2.0"
  s.platform = Gem::Platform::RUBY
  s.summary = summary="Habitat is a repository handler for multiple hanami applications."
  s.license = "MIT"

  s.description = <<~EOF
    #{summary}
  EOF

  s.files = Dir['{bin/*,plugins/**/*,lib/**/*,test/**/*,skel/**/*,scripts/**/*,config/**/*}'] +
    %w(LICENSE habitat.gemspec Rakefile.rb)

  s.bindir = 'bin'
  #s.executables << 'rackup'
  s.require_path = 'lib'


  s.author = 'Michael Trommer'
  s.email = 'mictro@gmail.com'

  s.homepage = 'https://github.com/entropie/habitat'

  s.required_ruby_version = '>= 2.5.7'

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/entropie/habitat//issues",
    "source_code_uri"   => "https://github.com/entropie/habitat"
  }

  # s.add_development_dependency 'minitest', "~> 5.0"
  # s.add_development_dependency 'minitest-sprint'
  # s.add_development_dependency 'minitest-global_expectations'

  # s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest', '~> 5.14.4'
  s.add_development_dependency 'rack-mini-profiler', '~> 2.3.3'
  s.add_development_dependency 'flamegraph', '~> 0.9.5'
  s.add_development_dependency 'fast_stack', '~> 0.2.0'

  s.add_dependency 'bundler'
  s.add_dependency 'rake', '~> 13.0.6'
  s.add_dependency 'hanami', '~> 1.3.2'
  s.add_dependency 'hanami-model', '~> 1.3.2'
  s.add_dependency 'rack-cache', '~> 1.13.0'
  s.add_dependency 'subcommand', '~> 1.0.7'
  s.add_dependency 'sqlite3', '~> 1.4.2'
  s.add_dependency 'memcached', '~> 1.8.0'
  s.add_dependency 'puma', '>= 5.5.2', '< 5.7.0'
  s.add_dependency 'rack', '~> 2.2.3'
  s.add_dependency 'nokogiri', '~> 1.12.5'
  s.add_dependency 'haml', '~> 5.2.2'
  s.add_dependency 'sassc', '~> 2.4.0'
  s.add_dependency 'jwt', '~> 2.3.0'
  s.add_dependency 'warden', '~> 1.2.9'
  s.add_dependency 'bcrypt', '~> 3.1.16'
  s.add_dependency 'sequel', '~> 4.49.0'
  s.add_dependency 'redcarpet', '~> 3.5.1'
  s.add_dependency 'rake-compiler', '~> 1.1.1'
  s.add_dependency 'unicorn', '~> 6.0.0'
  s.add_dependency 'dimensions', '~> 1.3.0'
  s.add_dependency 'pony', '~> 1.13.1'
  s.add_dependency 'builder', '~> 3.2.4'
  s.add_dependency 'sshkit', '~> 1.21.2'
  s.add_dependency 'capistrano', '~> 3.16.0'
  s.add_dependency 'capistrano-bundler', '~> 2.0.1'
  s.add_dependency 'capistrano-rvm', '~> 0.1.2'
  s.add_dependency 'multi_json', '~> 1.15.0'
  s.add_dependency 'roar', '~> 1.1.0'
  s.add_dependency 'uglifier', '~> 4.2.0'
  # s.add_dependency 'webp-ffi', '~> 0.3.1'
  s.add_dependency 'dotenv', '~> 2.7.6'
  s.add_dependency 'flickraw', '~> 0.9.10'
end
