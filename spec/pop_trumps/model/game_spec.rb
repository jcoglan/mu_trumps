require 'spec_helper'

describe PopTrumps::Game do
  let(:alice) { Factory :user, :lastfm_username => "alice" }
  let(:bob)   { Factory :user, :lastfm_username => "bob"   }
  
  describe "join" do
    describe "when there are no games" do
      it "returns a new game with one participant" do
        game = PopTrumps::Game.join(alice)
        game.should be_kind_of(PopTrumps::Game)
        game.users.should == [alice]
      end
    end
    
    describe "when there is a game with one participant" do
      before do
        @game = PopTrumps::Game.create(:users => [alice])
      end
      
      it "returns the waiting game with two participants" do
        game = PopTrumps::Game.join(bob)
        game.should == @game
        game.users.should == [alice, bob]
      end
    end
  end
  
  describe "cards" do
    before do
      Factory :artist, :name => "Imogen Heap"
      Factory :artist, :name => "Justin Bieber"
      Factory :artist, :name => "Lady Gaga"
    end
    
    it "is populated from random artists when a game is created" do
      all_artists = PopTrumps::Artist.all
      PopTrumps::Artist.should_receive(:random).with(52).and_return all_artists
      game = PopTrumps::Game.create
      game.cards.map(&:artist).should == all_artists
    end
  end
end
