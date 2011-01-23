module PopTrumps
  class Card < ActiveRecord::Base
    belongs_to :artist
    belongs_to :game
    
    validates_presence_of :artist, :game
  end
end
