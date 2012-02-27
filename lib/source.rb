module WOWCombatLog
  class Actors
    def initialize
      @members = {}
    end

    def members
      return @members.values
    end

    def [](identifier)
      return @members[identifier] || @members.values.find {|member| member.name == identifier}
    end

    def add(name, unique_id, flags)
      actor = @members[unique_id]
      if not actor
        actor = Actor.new(name, unique_id, flags)
        @members[unique_id] = actor
      end
      return actor
    end

    def players
      return members.select {|actor| actor.player?}
    end
  end

  class Actor
    attr_reader :caused_events
    attr_reader :taken_events

    attr_reader :name
    attr_reader :unique_id
    attr_reader :flags

    attr_reader :summoned_by
    
    def initialize(name, unique_id, flags)
      @name = name
      @unique_id = unique_id
      @flags = flags

      @player = (@flags == "0x511" || @flags == "0x512" || @flags == "0x20512")
      @summoned_by = nil

      @caused_events = []
      @taken_events = []
    end

    def activity
      return caused_events.size
    end

    def player?
      return @player
    end

    def summoned?
      return !@summoned_by.nil?
    end

    def summoned_by=(summoner)
      @summoned_by = summoner
    end
    
    def identify
      return {:player => player?, :name => name, :unique_id => unique_id, :flags => flags}
    end

  end
end
