require_relative "lib/habitat"
require_relative "test/test"


namespace :test do
  task :test do
    p Habitat::Quarters
  end

  task :plugins do
    Habitat::Tests[:plugins].run_test(ENV["TEST"])
  end
end
