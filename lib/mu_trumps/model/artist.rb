module MuTrumps
  class Artist < ActiveRecord::Base
    has_many :identifiers
    has_many :statistics
    validates_presence_of :name
    
    def self.random(n)
      all[0...n]
    end
    
    def assign(stat, value)
      statistic = statistics.find_or_create_by_name(stat)
      statistic.update_attribute(:value, value)
    end
    
    def ids
      reduce_to_hash(identifiers)
    end

    def stats
      reduce_to_hash(statistics)
    end

    def reduce_to_hash(enum)
      stats = {}
      enum.each do |statistic|
        stats[statistic.name] = statistic.value
      end
      stats
    end
  end
end
