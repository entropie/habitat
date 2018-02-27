# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

set :application, "foobar"

set :repo_url, "git://github.com/entropie/habitat.git"

set :habitat_url, "/home/mit/Source/habitats/#{fetch(:application)}"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/habitats/foobar"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

server "hive", roles: %w{web app db}
set    :branch, 'master'

set    :bundle_gemfile, -> { release_path.join('quarters', fetch(:application), 'Gemfile') } 

namespace :habitat do

  task :checkout do
    on roles(:app) do
      within release_path.join("quarters") do
        execute :git, "clone #{fetch(:habitat_url)}"
      end
    end
  end
  after "habitat:checkout", "habitat:bundle"

  task :setup do
    on roles(:app) do
    end
  end
  after "habitat:setup", "habitat:checkout"


  task :bundle do
    on fetch(:bundle_servers) do
      within release_path.join("quarters/#{fetch(:application)}") do
        with fetch(:bundle_env_variables) do
          options = []
          options << "--gemfile #{fetch(:bundle_gemfile)}" if fetch(:bundle_gemfile)
          options << "--path #{fetch(:bundle_path)}" if fetch(:bundle_path)
          unless test(:bundle, :check, *options)
            options << "--binstubs #{fetch(:bundle_binstubs)}" if fetch(:bundle_binstubs)
            options << "--jobs #{fetch(:bundle_jobs)}" if fetch(:bundle_jobs)
            options << "--without #{fetch(:bundle_without)}" if fetch(:bundle_without)
            options << "#{fetch(:bundle_flags)}" if fetch(:bundle_flags)
            execute :pwd
            execute :bundle, :install, *options
          end
        end
      end
    end
  end
  

end

namespace :bundler do
  task :install do
    p 1
  end
end

Rake::Task["bundler:install"].clear_actions

namespace :deploy do

  after 'deploy:log_revision', 'habitat:setup'

  task :setup do
    on roles(:all) do host
      execute :pwd
      info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
    end
  end
end
  
