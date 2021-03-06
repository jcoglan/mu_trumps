require 'spec_helper'

describe MuTrumps::Web::Application do
  include Rack::Test::Methods
  let(:app)  { MuTrumps::Web::Application.new }
  let(:json) { JSON.parse(last_response.body) }
  
  def artist_json(artist)
    {"id" => artist.id, "name" => artist.name, "image" => artist.image_url}
  end
  
  before do
    @imogen = Factory(:artist, :name => "Imogen Heap", :id => 100)
    @justin = Factory(:artist, :name => "Justin Bieber")
    @gaga   = Factory(:artist, :name => "Lady Gaga")
    @sufjan = Factory(:artist, :name => "Sufjan Stevens")
    
    MuTrumps::Artist.all.each_with_index do |artist, index|
      artist.assign("stamina", index)
    end
    
    @alice  = Factory(:user, :lastfm_username => "alice")
    @bob    = Factory(:user, :lastfm_username => "bob")
  end
  
  describe "/artists/:id" do
    before do
      artist = @imogen
      artist.assign("releases", 23)
      artist.assign("concerts", 1024)

      artist.identifiers << MuTrumps::Identifier.new(:name => "7digital", :value => "8321")
    end
    
    it "returns details for an artist" do
      get "/artists/100.json"
      json.should == {
        "id"    => 100,
        "name"  => "Imogen Heap",
        "identifiers" => {
          "7digital" => "8321"
        },
        "stats" => {
          "releases" => 23,
          "concerts" => 1024,
          "stamina"  => 0
        }
      }
    end
  end
  
  describe "/users/register.json" do
    it "returns an existing user" do
      post "/users/register.json", :username => "alice"
      json.should == {"id" => @alice.id, "username" => "alice"}
    end
    
    it "creates a new user" do
      MuTrumps::User.find_by_lastfm_username("cecil").should be_nil
      post "/users/register.json", :username => "cecil"
      cecil = MuTrumps::User.find_by_lastfm_username("cecil")
      json.should == {"id" => cecil.id, "username" => "cecil"}
    end
  end
  
  describe "/games.json" do
    describe "with no waiting games" do
      it "creates a waiting game and returns the user's cards" do
        post "/games.json", :username => "someguy"
        game_id = MuTrumps::Game.first.id
        json.should == {
          "status" => "waiting",
          "id"     => game_id,
          "cards"  => [artist_json(@imogen), artist_json(@gaga)]
        }
      end
    end
    
    describe "with a waiting game" do
      before do
        @game = MuTrumps::Game.join(@alice)
      end
      
      it "makes the game ready and returns the user's cards" do
        post "/games.json", :username => "bob"
        json.should == {
          "status" => "ready",
          "id"     => @game.id,
          "cards"  => [artist_json(@justin), artist_json(@sufjan)]
        }
      end
      
      it "messages the user who started the game" do
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @alice, "start")
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @alice, "current_user", "username" => "alice")
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @bob,   "current_user", "username" => "alice")
        post "/games.json", :username => "bob"
      end
    end
  end
  
  describe "/games/:id.json" do
    before do
      @game = MuTrumps::Game.join(@alice)
      MuTrumps::Game.join(@bob)
    end
    
    it "returns the state of the game" do
      get "/games/#{@game.id}.json"
      json.should == {
        "status"       => "ready",
        "id"           => @game.id,
        "current_user" => "alice",
        "users" => {
          "alice" => 2,
          "bob"   => 2
        }
      }
    end
  end
  
  describe "/games/:id/cards/:username.json" do
    before do
      @game = MuTrumps::Game.join(@alice)
      MuTrumps::Game.join(@bob)
    end
    
    it "returns the current deck for the user" do
      get "/games/#{@game.id}/cards/alice.json"
      json.should == [artist_json(@imogen), artist_json(@gaga)]
    end
  end
  
  describe "/games/:id/plays.json" do
    before do
      MuTrumps::Game.join(@alice)
      @game = MuTrumps::Game.join(@bob)
    end
    
    it "returns an error if an illegal move is made" do
      post "/games/#{@game.id}/plays.json", :username => "bob", :artist_id => @justin.id, :stat => "stamina"
      json.should == {"status" => "error"}
    end
    
    it "lets the current player make a move" do
      post "/games/#{@game.id}/plays.json", :username => "alice", :artist_id => @imogen.id, :stat => "stamina"
      json.should == {"status" => "ok"}
    end
    
    it "notifies the waiting user of the play" do
      MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @bob, "play",
                                                        "username" => "alice",
                                                        "stat"     => "stamina",
                                                        "value"    => 0)
      
      post "/games/#{@game.id}/plays.json", :username => "alice", :artist_id => @imogen.id, :stat => "stamina"
    end
  end
  
  describe "/games/:id/ack.json" do
    before do
      MuTrumps::Game.join(@alice)
      @game = MuTrumps::Game.join(@bob)
      post "/games/#{@game.id}/plays.json", :username => "alice", :artist_id => @imogen.id, :stat => "stamina"
    end
    
    it "allows the waiting user to acknowledge the play" do
      post "/games/#{@game.id}/ack.json", :username => "bob"
      json.should == {"status" => "ok"}
    end
    
    it "notifies both players about the result of the round" do
      MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @bob,   "result", "result" => "win")
      MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @alice, "result", "result" => "lose")

      MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @bob, "cards", "cards" => [
          artist_json(@sufjan), artist_json(@imogen), artist_json(@justin)
        ])
      
      MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @alice, "cards", "cards" => [
          artist_json(@gaga)
        ])
      
      MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @alice, "current_user", "username" => "bob")
      MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @bob,   "current_user", "username" => "bob")
      
      post "/games/#{@game.id}/ack.json", :username => "bob"
    end
    
    describe "when the move results in game over" do
      before do
        post "/games/#{@game.id}/ack.json", :username => "bob"
        post "/games/#{@game.id}/plays.json", :username => "bob", :artist_id => @sufjan.id, :stat => "stamina"
      end
      
      it "notifies both players about the result of the round" do
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @bob,   "result", "result" => "win")
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @alice, "result", "result" => "lose")
        
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @bob, "cards", "cards" => [
            artist_json(@imogen), artist_json(@justin), artist_json(@gaga), artist_json(@sufjan)
          ])
          
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @alice, "cards", "cards" => [])
          
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @alice, "winner", "username" => "bob")
        MuTrumps::Web::Messaging.should_receive(:publish).with(@game, @bob,   "winner", "username" => "bob")
        
        post "/games/#{@game.id}/ack.json", :username => "alice"
      end
    end
  end
end
