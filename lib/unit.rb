require "event"

module WOWCombatLog
  module Events
    module Unit
      class BaseParty < BaseEvent
        def parse_type_specific_data(specific_data)
          @specific_data = specific_data
        end
      end

      class Died < BaseParty
      end

      class Destroyed < BaseParty
      end
    end
  end
end
