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


quarters.each do |quart|

  q = quarters[quart]
  


  command(quart.identifier) do |sopts|
    sopts.description = "options for quart #{quart.identifier}"
    sopts.banner = "Usage:"

    sopts.on("-p", "--plugins", "list plugins") do |b|
      puts "Enabled:   %s" % q.plugins.to_s
      puts "Available: %s" % q.plugins.available.to_s
    end

    sopts.on("-a", "--active plugin", "activate plugin") do |b|
      q.plugins.available[b].activate

    end

    sopts.on("-d", "--deactivate plugin", "deactivate plugin") do |b|
      q.plugins[b].deactivate
    end
  end
end

cmd = opt_parse


# log(:info, "lala")
