module PopTrumps
  class Game < ActiveRecord::Base
    has_many :cards
    has_and_belongs_to_many :users
    
    before_create :generate_deck
    
    DECK_SIZE = 52
    
    def self.join(user)
      game = last
      game = create unless game and game.users.size == 1
      game.users << user
      game
    end
    
  private
    
    def generate_deck
      self.cards = Artist.random(DECK_SIZE).map do |artist|
        Card.new(:artist => artist)
      end
    end
  end
end
