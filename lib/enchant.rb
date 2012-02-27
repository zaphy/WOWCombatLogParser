require "event"

module WOWCombatLog
  module Events
    module Enchant
      class BaseEnchant < BaseEvent
        def parse_type_specific_data(specific_data)
        end
      end

      
      class Removed < BaseEnchant
      end

      class Applied < BaseEnchant
      end
    end
  end
end
