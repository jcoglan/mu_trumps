require 'spec_helper'

describe PopTrumps::Game do
  before do
    @imogen = Factory(:artist, :name => "Imogen Heap", :id => 100)
    @justin = Factory(:artist, :name => "Justin Bieber")
    @gaga   = Factory(:artist, :name => "Lady Gaga")
    @sufjan = Factory(:artist, :name => "Sufjan Stevens")
  end
  
  let(:alice) { Factory :user, :lastfm_username => "alice" }
  let(:bob)   { Factory :user, :lastfm_username => "bob"   }
  
  describe "join" do
    before do
      PopTrumps::Artist.stub(:random).and_return PopTrumps::Artist.all
    end
    
    describe "when there are no games" do
      let(:game) { PopTrumps::Game.join(alice) }
      
      it "returns a new game with one participant" do
        game.should be_kind_of(PopTrumps::Game)
        game.users.should == [alice]
      end
      
      it "returns a game in the waiting state" do
        game.status.should == "waiting"
      end
      
      it "assigns half the game deck to the user" do
        game.cards_for(alice).map { |c| c.artist.name }.should == ["Imogen Heap", "Lady Gaga"]
      end
    end
    
    describe "when there is a game with one participant" do
      let(:game) { PopTrumps::Game.join(bob) }
      
      before do
        @existing_game = PopTrumps::Game.create(:users => [alice])
      end
      
      it "returns the waiting game with two participants" do
        game.should == @existing_game
        game.users.should == [alice, bob]
      end
      
      it "returns a game in the ready state" do
        game.status.should == "ready"
      end
      
      it "assigns the other half of the game deck to the user" do
        game.cards_for(bob).map { |c| c.artist.name }.should == ["Justin Bieber", "Sufjan Stevens"]
      end
    end
  end
  
  describe "cards" do
    it "is populated from random artists when a game is created" do
      all_artists = PopTrumps::Artist.all
      PopTrumps::Artist.should_receive(:random).with(52).and_return all_artists
      game = PopTrumps::Game.create
      game.cards.map(&:artist).should == all_artists
    end
  end

  describe "play" do
    before do
      PopTrumps::Game.join(alice)
      @game = PopTrumps::Game.join(bob)

      PopTrumps::Artist.all.each_with_index do |artist, index|
        artist.assign("stamina", index)
      end
    end

    it "throws an error if the wrong player tries to play" do
      @game.current_user.should == alice
      lambda { @game.play(bob, @justin, "stamina") }.should raise_error(PopTrumps::Game::PlayOutOfTurn)
    end

    it "throws an error if the artist is not at the top of the user's deck" do
      @game.current_artist_for(alice).should == @imogen
      lambda { @game.play(alice, @gaga, "stamina") }.should raise_error(PopTrumps::Game::NotInDeck)
    end
    
    it "sets the current stat for the round" do
      @game.current_stat.should be_nil
      @game.play(alice, @imogen, "stamina")
      @game.current_stat.should == "stamina"
    end
    
    it "decides the round when the other player acks" do
      @game.play(alice, @imogen, "stamina")
      @game.should_receive(:round_won_by).with(bob)
      @game.ack(bob)
      @game.current_stat.should be_nil
    end
    
    describe "when the attacker uses a stat the defense does not have" do
      before do
        @imogen.assign("soundcloud_meetings", 1)
      end
      
      it "lets the attacker win" do
        @game.play(alice, @imogen, "soundcloud_meetings")
        @game.should_receive(:round_won_by).with(alice)
        @game.ack(bob)
      end
    end
  end

  describe "round_won_by" do
    before do
      PopTrumps::Game.join(bob)
      @game = PopTrumps::Game.join(alice)
    end

    it "transfers both current cards to the deck of the winner" do
      @game.round_won_by(alice)
      @game.cards_for(alice).map(&:artist).should == [@sufjan, @imogen, @justin]
    end
    
    it "makes the winner of the round the current player" do
      @game.round_won_by(alice)
      @game.current_user.should == alice
    end
  end
end
