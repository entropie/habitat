#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require File.join(File.dirname(File.expand_path(__FILE__)), "../lib/habitat.rb")

identifier = ARGV.join.strip

dir = File.join(File.expand_path("~/Source/habitat/quarters"), identifier)

abort "need identifier of the beehive" if not identifier or identifier.empty?
abort "beehive #{dir} !exist" unless File.exist?(dir)

def sh(cmd)
  log :info, "running #{cmd}"
  puts `#{cmd}`
end

sh "ssh hive 'mkdir ~/Source/habitats/#{identifier} && cd ~/Source/habitats/#{identifier} && git init --bare'"
  

Dir.chdir(dir) do
  sh "git init"
  sh "git remote add origin ssh://hive/home/mit/Source/habitats/#{identifier}"
  sh "git add ."
  sh "git commit -am initial"
  sh "git push --set-upstream origin master"
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
