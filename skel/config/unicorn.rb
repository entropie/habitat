root = "/home/habitats/%%%identifier%%%/current"
working_directory root
pid "/home/unicorn/%%%identifier%%%.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.%%%identifier%%%.sock"
worker_processes 1
timeout 30

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end
