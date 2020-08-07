require_relative "lib/habitat"
require_relative "test/test"

require "fileutils"
require "pp"


def en(mod)
  Dir.chdir(Habitat::Source.join("plugins", "backend")) do
    ["controllers", "templates", "views"].each do |bk|
      target = "#{bk}/#{mod}"
      unless File.exist?(target)
        FileUtils.ln_s("../#{mod}/backend/#{bk}", target, :verbose => true)
      end
    end
  end
end


def gen(mod, name, action)

  cntrl = <<-HEREDOC
module Backend::Controllers::#{name.capitalize}
  class #{action.capitalize}
    include Api::Action

    def call(params)
    end
  end
end
HEREDOC



  view = <<-HEREDOC
module Backend::Views::#{name.capitalize}
  class #{action.capitalize}
    include Backend::View
  end
end
HEREDOC


  template = <<-HEREDOC
#{action}
HEREDOC


  Dir.chdir(Habitat::Source.join("plugins", mod, "backend")) do

    {
      "controllers/#{name}/#{action}.rb" => cntrl,
      "views/#{name}/#{action}.rb" => view,
      "templates/#{name}/#{action}.html.haml" => template
    }.each_pair do |fn, fc|
      if File.exist?(fn)
        warn "existing: #{fn}"
      else
        FileUtils.mkdir_p(File.dirname(fn), :verbose => true)
        File.open(fn, "w+"){|fp| fp.puts(fc)}
      end
    end
  end

  en(mod)
end



namespace :generate do
  task :action, [:module, :clz, :action] do |t, args|
    mod, clz, action = args[:module], args[:clz], args[:action]
    gen(mod, clz, action)

  end

  
end

namespace :test do
  task :test do
    p Habitat::Quarters
  end

  task :plugins do
    Habitat::Tests[:plugins].run_test(ENV["TEST"])
  end
end
