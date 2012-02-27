require "event"

# http://www.wowwiki.com/API_COMBAT_LOG_EVENT
module WOWCombatLog
  module Events
    module Spell
      
      class BaseSpell < BaseEvent
        def parse_type_specific_data(specific_data)
          #@specifics = specific_data
          @specifics[:amount] = Integer(specific_data[3]) rescue 0
          @specifics[:spell_name] = specific_data[1]
        end
      end
      
      module Periodic
        class BasePeriodic < BaseSpell
        end
        
        class Heal < BasePeriodic
        end
        
        class Energize < BasePeriodic
        end
        
        class Damage < BasePeriodic
        end

        class Drain < BasePeriodic
        end
        
        class Missed < BasePeriodic
        end
      end
      
      module Cast
        class BaseCast < BaseSpell
        end
        
        class Start < BaseCast
        end
        
        class Success < BaseCast
        end
        
        class Failed < BaseCast
        end
      end

      module Extra
        class Attacks < BaseSpell
        end
      end

      class Stolen < BaseSpell
      end

      class Drain < BaseSpell
      end
      
      class Heal < BaseSpell
      end
      
      class Interrupt < BaseSpell
      end
      
      class Aura < BaseSpell
        class Applied < Aura
          class Dose < Applied
          end
        end
        
        class Refresh < Aura
        end
        
        class Removed < Aura
          class Dose < Removed
          end
        end
        
        class Broken < Aura
          class Spell < Broken
          end
        end
      end
      
      class Damage < BaseSpell
      end
      
      class Missed < BaseSpell
      end
      
      class Energize < BaseSpell
      end
      
      class Create < BaseSpell
      end
      
      class Dispel < BaseSpell
      end
      
      class Summon < BaseSpell
      end
      
      class Resurrect < BaseSpell
      end

      class Instakill < BaseSpell
      end
    end
  end
end