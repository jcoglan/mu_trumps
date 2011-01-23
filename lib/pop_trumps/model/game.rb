module PopTrumps
  class Game < ActiveRecord::Base
    has_many :cards
    has_and_belongs_to_many :users, :uniq => true
    belongs_to :current_user, :class_name => 'PopTrumps::User'
    
    before_create :generate_deck
    
    DECK_SIZE = 52
    
    def self.join(user)
      game = last
      game = create unless game and game.users.size == 1
      game.add_player(user)
      game
    end
    
    def add_player(user)
      cards.each_with_index do |card, index|
        next unless (users.empty? and index.even?) or (not users.empty? and index.odd?)
        card.update_attribute(:user, user)
      end
      users << user
      self.current_user ||= user
      save
    end
    
    def cards_for(user)
      cards.select { |card| card.user == user }
    end
    
  private
    
    def generate_deck
      self.cards = Artist.random(DECK_SIZE).map do |artist|
        Card.new(:artist => artist)
      end
    end
  end
end
