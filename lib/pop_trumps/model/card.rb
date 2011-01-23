module PopTrumps
  class Card < ActiveRecord::Base
    belongs_to :artist
    belongs_to :game
    belongs_to :user
    
    validates_presence_of :artist, :game

    acts_as_list :scope => :game
  end
end
