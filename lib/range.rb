require "event"

module WOWCombatLog
  module Events
    module Range

      class BaseRange < BaseEvent
        def parse_type_specific_data(specific_data)
          @specifics[:amount] = Integer(specific_data[3]) rescue 0
        end
      end

      class Damage < BaseRange
      end

      class Missed < BaseRange
      end
    end
  end
end
