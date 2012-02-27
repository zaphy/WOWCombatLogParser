require "event"

module WOWCombatLog
  module Events
    module Swing

      class BaseSwing < BaseEvent
        def parse_type_specific_data(specific_data)
          #@specific_data = specific_data
          @specifics[:amount] = Integer(specific_data[0]) rescue 0
        end
      end

      class Damage < BaseSwing
      end
        
      class Missed < BaseSwing
      end

    end
  end
end
