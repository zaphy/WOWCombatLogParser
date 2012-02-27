require "lib/wowcombatlogparser"
require "find"

data_dir = File.join(File.dirname(__FILE__), "..", "data")

#Find.find(data_dir) do |path|
#  path = File.expand_path(path)
#  if path =~ /WoWCombatLog_/ and File.file?(path)
#    puts path
#    lr = WOWCombatLog::Reader.new(File.read(path))
#    pp lr.sources.keys.size
#  end
#end


lr = WOWCombatLog::Reader.new(File.read("#{data_dir}/WoWCombatLog_cata001.txt"))
  
puts lr.to_yaml
exit
#pp lr.detect_multiple_runs[0..10].map {|x| [x[0] / 60, x[1]]}
#exit

#lr = WOWCombatLog::Reader.new(File.read("#{data_dir}/WoWCombatLog_20100701_cotty_asael_donnerfaust_jandi.txt"))
#lr = WOWCombatLog::Reader.new(File.read("#{data_dir}/WoWCombatLog_20101111_Hellspawn_Andre.txt"))
#pp lr.events.compact.find_all {|x| x.destination_name == "Jandi" and x.specifics[:overheal] >= x.specifics[:amount]}.size
#pp lr.events.compact.size


#lr.event_samples(:damage, :duration => 1).each do |event_sample|
#  filtered = event_sample#.filter(:source_name => "Gwirs")
#  if not filtered.empty?
#    p filtered.sum(:amount)
#    puts filtered.highest(:amount).simple
#    puts filtered.lowest(:amount).simple
#  end
#end


p lr.players.size

lr.players.each do |player|
  pp player.identify
end

exit

#lr.actors.each do |actor|
#  if actor.summoned? and actor.summoned_by.player?
#    p [actor.summoned_by.identify, actor.identify]
#  end
#end

damage = []
lr.event_samples(:damage, :duration => 1).each do |event_samples|
  sample_damage = event_samples.filter(:source_name => "Alveran").sum(:amount) || 0
  damage << sample_damage
end

require "rubygems"
require "gruff"

g = Gruff::Bar.new
g.title = "My Graph"

g.data("Damage", damage)
#g.data("Heal", heal.map{|event_data| event_data.last})

g.write("#{data_dir}/WoWCombatLog.png")