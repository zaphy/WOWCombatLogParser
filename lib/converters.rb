module WOWCombatLog
  module Events
    module Converters
      class Converter
        def self.convert(data)
          return self.const_get("CONVERSION")[data]
        end
      end
      
      class NonConverter
        def self.convert(data)
          return data
        end
      end
      
      class IntConverter
        def self.convert(data)
          return Integer(data)
        end
      end
      
      class BoolConverter
        def self.convert(data)
          return data == "1"
        end
      end
      
      class NameConverter
        def self.convert(data)
          return Iconv.iconv('LATIN1', 'UTF-8', data).first
        end
      end

      
      class SpellId < NonConverter
      end
      
      class SpellSchool < Converter
        CONVERSION = {"0x8" => :nature}
      end
      
      class SpellName < NameConverter
      end
      
      class Amount < IntConverter
        CONVERSIONS = {"RESIST" => 0}
      end
      
      class Overheal < IntConverter
      end
      
      class Absorbed < IntConverter
      end
      
      class Critical < BoolConverter
      end
      
      class RefreshType < Converter
        CONVERSION = {"-2" => :health, "0" => :mana, "1" => :rage, "2" => :focus, "3" => :energy, "4" => :pet_happiness, "5" => :runes, "6" => :runic_power}
      end
    end
  end
end          
