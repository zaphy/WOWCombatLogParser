module WOWCombatLog
  module Events
    class BaseEvent
      attr_reader :source_data
      attr_reader :destination_data

      attr_reader :specifics
      
      def self.read_as(field_name, data)
        Converters.const_get(field_name.to_s.split("_").map{|x| x.capitalize}.join).convert(data)
      end

      def self.parse_timestamp(timestamp)
        date, time = timestamp.split(" ")
        time, msec = time.split(".")
        hour, min, sec = time.split(":").map {|component| component.to_i(10)}
        month, day = date.split("/").map {|component| component.to_i(10)}
        year = Time.now.year
        return Time.mktime(year, month, day, hour, min, sec, msec.to_i(10))
      end
      
      def initialize(timestamp, data)
        @source = nil
        @destination = nil
        
        @timestamp = self.class.parse_timestamp(timestamp)
        
        @source_data = {:name => Converters::NameConverter.convert(data[1]),
          :unique_id => data[0],
          :flags => data[2]
        }

        @destination_data = {:name => Converters::NameConverter.convert(data[4]),
          :unique_id => data[3],
          :flags => data[5]
        }

        @specifics = {:raw => data[6..-1]}
        parse_type_specific_data(data[6..-1])
      end

      def source=(the_source)
        @source = the_source
        the_source.caused_events << self
      end

      def destination=(the_destination)
        @destination = the_destination
        the_destination.taken_events << self
      end

      def timestamp
        @timestamp#.to_f
      end

      def event_type
        return self.class.name.split("::").map {|segment| segment.downcase.to_sym}
      end

      def periodic?
        return type?(:periodic)
      end

      def type?(event_type)
        return self.event_type.include?(event_type)
      end
      
      def simple
        "#{event_type[-2..-1].join(' ')}[#{periodic?}]: #{@source_name} -> #{@destination_name}: #{specifics.inspect}"
      end

      def source_name
        return @source.name
      end

      def destination_name
        return @destination.name
      end

      def inspect
        return [self.class, @specifics[:raw]].inspect
      end

      def method_missing(name, *args, &block)
        if @specifics.has_key?(name) and args.empty? and not block_given?
          return @specifics[name]
        else
          p self.simple
          p [name, args]
          super
        end
      end
    end
  end
end