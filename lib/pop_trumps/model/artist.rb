module PopTrumps
  class Artist < ActiveRecord::Base
    has_many :statistics
    validates_presence_of :name
    
    def assign(stat, value)
      statistic = statistics.find_or_create_by_name(stat)
      statistic.update_attribute(:value, value)
    end
    
    def stats
      stats = {}
      statistics.each do |statistic|
        stats[statistic.name] = statistic.value
      end
      stats
    end
  end
end
