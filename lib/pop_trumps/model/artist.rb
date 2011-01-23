module PopTrumps
  class Artist < ActiveRecord::Base
    validates_presence_of :name
  end
end
