require "event"

module WOWCombatLog
  module Events
    module Environmental
      class BaseEnvironmental < BaseEvent
        def parse_type_specific_data(specific_data)
          @specifics[:amount] = 0
        end
      end

      class Damage < BaseEnvironmental
      end
    end
  end
end
