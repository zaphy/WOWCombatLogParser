require "event"

module WOWCombatLog
  module Events
    module Damage

      class BaseDamage < BaseEvent
        def parse_type_specific_data(specific_data)
          @specifics[:amount] = Integer(specific_data[3]) rescue 0
        end
      end

      class Split < BaseDamage
      end

      class Shield < BaseDamage
        class Missed < Shield
        end
      end
    end
  end
end
