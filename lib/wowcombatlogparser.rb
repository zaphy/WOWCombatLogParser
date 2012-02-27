require "rubygems"
require "fastercsv"

require "iconv"
require "yaml"

require "pp"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "converters"
require "spell"
require "swing"
require "range"
require "damage"
require "party"
require "unit"
require "environmental"
require "enchant"

require "source"

$KCODE = "UTF8"

# http://www.wowwiki.com/API_COMBAT_LOG_EVENT
module WOWCombatLog
  class Event
    def self.parse_from_line(line)
      timestamp, data = line.scan(/^(.*?)\s\s(.*)$/).first
      type, *type_data = FCSV.parse(data).first
      klass = Events
      result = nil
      begin
        type_hierarchy = type.split("_")
        type_hierarchy.each do |type_name|
          klass = klass.const_get(type_name.capitalize)
        end
        result = klass.new(timestamp, type_data)
      rescue NameError
        # unimplemented type
        puts line if line !~ /SPELL/
        raise
      end
      return result
    end

    def initialize(timestamp, data)
      @timestamp = timestamp
    end
  end

  class Reader
    def initialize(data)
      @events = []
      @actors = Actors.new
      data.each_line do |line|
        event = Event.parse_from_line(line)
        
        source_data = event.source_data
        destination_data = event.destination_data

        source = @actors.add(source_data[:name], source_data[:unique_id], source_data[:flags])
        destination = @actors.add(destination_data[:name], destination_data[:unique_id], destination_data[:flags])

        event.source = source
        event.destination = destination

        if event.type?(:summon)
          destination.summoned_by = source
        end
        
        @events << event
      end
    end

    def events(event_type=nil)
      return @events if event_type.nil?
      return @events.find_all {|event| event.type?(event_type)}
    end

    def detect_multiple_runs
      offsets = []
      @events.each_with_index do |event, index|
        next if index == 0
        offsets << [(event.timestamp - events[index-1].timestamp), event]
      end
      return offsets.sort_by {|x| x[0]}.reverse
    end

    def event_samples(event_type, options={:duration=>1})
      events = events(event_type)
      result = []
      sample = EventSample.new(events.shift)
      events.each do |event|
        if event.timestamp - sample.first_timestamp < options[:duration]
          sample << event
        else
          result << sample
          sample = EventSample.new(event)
        end
      end

      return result
    end

    def actors
      return @actors.members
    end

    def players
      return @actors.players
    end
  end

  class EventSample
    attr_reader :events
    def initialize(*events)
      @events = events.flatten
    end

    def <<(event)
      @events << event
    end

    def empty?
      return @events.empty?
    end

    def first_timestamp
      earliest_event = @events.min {|event_a, event_b| event_a.timestamp <=> event_b.timestamp}
      return earliest_event.timestamp
    end

    def filter(options={})
      resulting_events = @events
      options.each_pair do |filter_key, filter_value|
        selected = @events.select {|event| event.send(filter_key) == filter_value}
        resulting_events = resulting_events & selected
      end
      return self.class.new(resulting_events)
    end

    def highest(value)
      return @events.first if @events.size <= 1
      result = @events.first
      @events[1..-1].each do |event|
        result = event if event.send(value) > result.send(value)
      end
      return result
    end

    def lowest(value)
      return @events.first if @events.size <= 1
      result = @events.first
      @events[1..-1].each do |event|
        result = event if event.send(value) < result.send(value)
      end
      return result
    end

    def sum(value)
      return nil if empty?
      result = 0
      @events.each {|event| p event if event.send(value).nil?}
      @events.each {|event| result += event.send(value)}
      return result
    end

    def to_s
      @events.map {|event| event.amount}.join("\n")
    end
  end
end


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