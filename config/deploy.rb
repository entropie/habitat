require 'capistrano/bundler'

identifier = File.expand_path(__FILE__).split("/")[-3]

require_relative File.join(File.expand_path(__FILE__), "../../../../lib/habitat.rb")
Q = Habitat.quart = Habitat::Quarters[identifier]

set :application, Q.identifier.to_s

set :repo_url, "git://github.com/entropie/habitat.git"

set :habitat_url, "/home/mit/Source/habitats/#{fetch(:application)}"
set :media_path,  "/home/mit/Data/quarters/media/#{fetch(:application)}"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/habitats/#{fetch(:application)}"


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

set    :habitat, release_path.join("quarters", fetch(:application))

set    :nginx_config, "/etc/nginx/sites-enabled/habitat-#{fetch(:application)}.conf"
set    :unicorn_init, "/etc/init.d/unicorn_#{fetch(:application)}"


def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def remote_link_exists?(full_path)
    'true' ==  capture("if test -L #{full_path}; then echo 'true'; fi").strip
end


namespace :habitat do

  [:start, :stop].each do |action|
    task action do
      on roles(:app) do
        within fetch(:habitat) do
          execute :bundle, "exec #{fetch(:unicorn_init)} #{action}"
        end
      end
    end
  end

  task :restart do
    on roles(:app) do
      within fetch(:habitat) do
        execute :bundle, "exec #{fetch(:unicorn_init)} stop"
        execute :bundle, "exec #{fetch(:unicorn_init)} start"
      end
    end
  end

  
  task :link_files do
    on roles(:app) do
      habitat_root = fetch(:habitat)
      
      unless remote_link_exists?(fetch(:nginx_config))
        sudo :ln, "-s #{habitat_root.join("config/nginx.conf")} #{fetch(:nginx_config)}"
      end
      
      unless remote_link_exists?(fetch(:unicorn_init))
        sudo :ln, "-s #{habitat_root.join("config/unicorn_init.sh")} #{fetch(:unicorn_init)} "
      end
    end
  end

  task :link_media do
    on roles(:app) do
      habitat_media_path = fetch(:habitat).join("media")
      unless remote_link_exists?(habitat_media_path)
        execute :ln, "-s #{fetch(:media_path)} #{habitat_media_path}"
      end
    end
  end

  task :setup_assets do
    on roles(:app) do
      within fetch(:habitat) do
        execute :npm, "install"
        execute :npm, "run production"
      end
    end
  end

  task :checkout do
    on roles(:app) do
      within release_path.join("quarters") do
        execute :git, "clone #{fetch(:habitat_url)}"
      end
    end
  end
  after "habitat:checkout", "habitat:bundle"
  after "habitat:checkout", "habitat:link_media"

  task :setup do
    on roles(:app) do
      invoke "habitat:checkout"
      invoke "habitat:link_files"
      invoke "habitat:setup_assets"
    end
  end

  after "habitat:setup", "habitat:restart"

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
            execute :bundle, :install, *options
          end
        end
      end
    end
  end
  

end

Rake::Task["bundler:install"].clear_actions

after 'deploy:log_revision', 'habitat:setup'
