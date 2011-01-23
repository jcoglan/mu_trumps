module PopTrumps
  class Game < ActiveRecord::Base
    has_many :cards, :order => :position
    has_and_belongs_to_many :users, :uniq => true
    belongs_to :current_user, :class_name => 'PopTrumps::User'
    
    before_create :generate_deck
    
    DECK_SIZE = 52
    WAITING   = 'waiting'
    READY     = 'ready'
    
    class PlayOutOfTurn < StandardError ; end
    class NotInDeck     < StandardError ; end

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
    
    def current_artist_for(user)
      cards_for(user).first.artist
    end

    def play(user, artist, stat_name)
      raise PlayOutOfTurn unless user == current_user
      raise NotInDeck unless current_artist_for(user) == artist
      update_attribute(:current_stat, stat_name)
    end
    
    def ack(user)
      raise PlayOutOfTurn unless user != current_user
      attack, defense = [current_user, user].map { |u| current_artist_for(u).stats[current_stat] }
      if attack > defense
        round_won_by(current_user)
      elsif defense > attack
        round_won_by(user)
      end
      update_attribute(:current_stat, nil)
    end

    def round_won_by(winner)
      loser = users.reject { |u| u == winner }.first
      top_cards = [loser, winner].map { |u| cards_for(u).first }
      top_cards.each do |card|
        card.reload
        card.update_attribute(:user, winner)
        card.move_to_bottom
      end
      update_attribute(:current_user, winner)
      reload
    end

    def status
      case users.count
      when 1 then WAITING
      when 2 then READY
      end
    end
    
  private
    
    def generate_deck
      self.cards = Artist.random(DECK_SIZE).map do |artist|
        Card.new(:artist => artist)
      end
    end
  end
end
