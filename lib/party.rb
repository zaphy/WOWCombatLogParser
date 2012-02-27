require "event"

module WOWCombatLog
  module Events
    module Party
      class BaseParty < BaseEvent
        def parse_type_specific_data(specific_data)
          @specific_data = specific_data
        end
      end

      class Kill < BaseParty
      end
    end
  end
end
