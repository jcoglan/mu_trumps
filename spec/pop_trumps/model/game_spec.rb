require 'spec_helper'

describe PopTrumps::Game do
  before do
    Factory :artist, :name => "Imogen Heap"
    Factory :artist, :name => "Justin Bieber"
    Factory :artist, :name => "Lady Gaga"
    Factory :artist, :name => "Sufjan Stevens"
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
end
