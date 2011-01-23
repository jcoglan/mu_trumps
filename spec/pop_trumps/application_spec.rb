require 'rack/test'
require 'spec_helper'

describe PopTrumps::Application do
  include Rack::Test::Methods
  let(:app)  { PopTrumps::Application.new }
  let(:json) { JSON.parse(last_response.body) }
  
  before do
    @imogen = Factory(:artist, :name => "Imogen Heap", :id => 100)
    @justin = Factory(:artist, :name => "Justin Bieber")
    @gaga   = Factory(:artist, :name => "Lady Gaga")
    @sufjan = Factory(:artist, :name => "Sufjan Stevens")
    
    PopTrumps::Artist.all.each_with_index do |artist, index|
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
    end
    
    it "returns details for an artist" do
      get "/artists/100.json"
      json.should == {
        "id"    => 100,
        "name"  => "Imogen Heap",
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
      PopTrumps::User.find_by_lastfm_username("cecil").should be_nil
      post "/users/register.json", :username => "cecil"
      cecil = PopTrumps::User.find_by_lastfm_username("cecil")
      json.should == {"id" => cecil.id, "username" => "cecil"}
    end
  end
  
  describe "/games.json" do
    describe "with no waiting games" do
      it "creates a waiting game and returns the user's cards" do
        post "/games.json", :username => "someguy"
        game_id = PopTrumps::Game.first.id
        json.should == {
          "status" => "waiting",
          "id"     => game_id,
          "cards"  => [
            {"id" => @imogen.id, "name" => @imogen.name, "image" => @imogen.image_url},
            {"id" => @gaga.id,   "name" => @gaga.name,   "image" => @gaga.image_url }
          ]
        }
      end
    end
    
    describe "with a waiting game" do
      before do
        @game = PopTrumps::Game.join(@alice)
      end
      
      it "makes the game ready and returns the user's cards" do
        post "/games.json", :username => "bob"
        json.should == {
          "status" => "ready",
          "id"     => @game.id,
          "cards"  => [
            {"id" => @justin.id, "name" => @justin.name, "image" => @imogen.image_url},
            {"id" => @sufjan.id, "name" => @sufjan.name, "image" => @imogen.image_url}
          ]
        }
      end
      
      it "messages the user who started the game" do
        PopTrumps::Messaging.should_receive(:publish).with(@alice, "start")
        PopTrumps::Messaging.should_receive(:publish).with(@alice, "current_user", "username" => "alice")
        PopTrumps::Messaging.should_receive(:publish).with(@bob,   "current_user", "username" => "alice")
        post "/games.json", :username => "bob"
      end
    end
  end
  
  describe "/games/:id.json" do
    before do
      @game = PopTrumps::Game.join(@alice)
      PopTrumps::Game.join(@bob)
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
      @game = PopTrumps::Game.join(@alice)
      PopTrumps::Game.join(@bob)
    end
    
    it "returns the current deck for the user" do
      get "/games/#{@game.id}/cards/alice.json"
      json.should == [
        {"id" => @imogen.id, "name" => @imogen.name, "image" => @imogen.image_url},
        {"id" => @gaga.id,   "name" => @gaga.name,   "image" => @gaga.image_url }
      ]
    end
  end
  
  describe "/games/:id/plays.json" do
    before do
      PopTrumps::Game.join(@alice)
      @game = PopTrumps::Game.join(@bob)
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
      PopTrumps::Messaging.should_receive(:publish).with(@bob, "play",
                                                        "username" => "alice",
                                                        "stat"     => "stamina",
                                                        "value"    => 0)
      
      post "/games/#{@game.id}/plays.json", :username => "alice", :artist_id => @imogen.id, :stat => "stamina"
    end
  end
  
  describe "/games/:id/ack.json" do
    before do
      PopTrumps::Game.join(@alice)
      @game = PopTrumps::Game.join(@bob)
      post "/games/#{@game.id}/plays.json", :username => "alice", :artist_id => @imogen.id, :stat => "stamina"
    end
    
    it "allows the waiting user to acknowledge the play" do
      post "/games/#{@game.id}/ack.json", :username => "bob"
      json.should == {"status" => "ok"}
    end
    
    it "notifies both players about the result of the round" do
      PopTrumps::Messaging.should_receive(:publish).with(@alice, "current_user", "username" => "bob")
      PopTrumps::Messaging.should_receive(:publish).with(@bob,   "current_user", "username" => "bob")
      
      PopTrumps::Messaging.should_receive(:publish).with(@bob,   "result", "result" => "win")
      PopTrumps::Messaging.should_receive(:publish).with(@alice, "result", "result" => "lose")
      
      post "/games/#{@game.id}/ack.json", :username => "bob"
    end
  end
end
