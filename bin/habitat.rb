#!/usr/bin/env ruby

require File.join(File.dirname(File.expand_path(__FILE__)), "..", "lib", "habitat.rb")

include Subcommands

include Habitat

Quarters::Quarters.read_dir


global_options do |opts|
  opts.banner = "Usage: hive [options] [subcommand [options]]"
  opts.description = "The Hive."
  opts.separator ""
  opts.separator "Global options are:"

  opts.on("-l", "--list", "List all the beehives") do
    
  end

end

add_help_option

command(:create) do |sopts|
  sopts.banner = "Usage hive create [options]"
  sopts.description = "create a new beehive and make the bees swarm"
  sopts.separator ""

  sopts.on("-n", "--name quart", "name of quart") do |quart|
    new_quart = Quarters::DummyQuart.create(quart)
    new_quart.create
  end
end


def app_run(arg)
  system "bundle exec hanami #{arg}"
end

quarters.each do |quart|

  q = Habitat.quart = quart

  command(quart.identifier) do |sopts|
    Habitat._require q.app_root("config/environment.rb")

    sopts.description = "options for quart #{quart.identifier}"
    sopts.banner = "Usage:"

    sopts.on("-p", "--plugins", "list plugins") do |b|
      puts "Enabled:   %s" % q.plugins.to_s
      puts "Available: %s" % q.plugins.available.to_s
    end

    sopts.on("-a", "--activate plugin", "activate plugin") do |b|
      q.plugins.available[b].activate
    end

    sopts.on("-d", "--deactivate plugin", "deactivate plugin") do |b|
      q.plugins[b].deactivate
    end

    sopts.on("-R", "--routes", "show routes") do
      app_run("routes")
    end

    # sopts.on("-S", "--start", "start local development server") do
    #   app_run("server")
    # end

    sopts.on("-U", "--uglifi", "asd") do
      q.prepare_assets_for_production
    end

    if q.plugins.activated?(:user)

      Habitat.add_adapter(:user, User::Database.with_adapter.new(q.media_path))
      user_adapter = Habitat.adapter(:user)

      sopts.on("-U", "--print-users", "put users") do
        user_adapter.user.each do |u|
          puts u
        end

      end

      sopts.on("-u", "--add-user", "add user") do
        opts = {}
        [:name, :password, :email].each do |k|
          print "%20s " % [k.to_s]
          opts[k] = STDIN.gets.strip
        end

        user_adapter.create(opts)
      end
    end


    if q.plugins.activated?(:projectsettings)
      sopts.on("-c", "--config", "get projectsettings") do
        puts ProjectSettings.to_s
      end

      sopts.on("-C", "--set-config key,value", "set key value pair in projectsettings") do |keyvalue|
        key, value = keyvalue.split(",")
        C[key] = value
        C.write
      end
      sopts.on("-D", "--delete-config key", "delete key from projectsettings") do |key|
        C.delete(key)
      end
    end

    if q.plugins.activated?(:snippets)
      sopts.on("-s", "--snippets", "snippets") do
        puts Snippets.all
        p 1
      end

      sopts.on("-g", "--get-snippet SNIPPET", "get snippet") do |k|
        p Habitat.adapter(:snippets)[k].to_s
      end

      sopts.on("-S", "--create-snippet ident.kind", "create a snippet") do |key|
        k, v = key.split(".")
        snippet = Habitat.adapter(:snippets).create(k.to_sym, "", (v && v.to_sym) || Snippets::DEFAULT_SNIPPET_TYPE)
        #snippet.create
        p 1
      end

      if q.plugins.activated?(:tumblog)
        
        token = File.readlines(File.expand_path("~/.tumbldog.token")).join.strip or raise "no token provided in ~/.tumbldog.token"
        Tumblog.token = token
        sopts.on("-A", "--submit value", "post") do |val|

          pp Tumblog::Api.submit(val)
        end

      end

      if q.plugins.activated?(:vgwort)

        sopts.on("", "--vgwort-initialize", "initializes vgwort database from ~media/vgwort.csv") do |key|
          VGWort.initialize
        end

        sopts.on("", "--vgwort-attach", "initializes vgwort database from ~media/vgwort.csv") do |key|
          Habitat.adapter(:blog).posts.each do |post|
            post.with_plugin(VGWort).attach_id
          end
        end
        

      end
    end
    
  end
  
end

cmd = opt_parse


# log(:info, "lala")
