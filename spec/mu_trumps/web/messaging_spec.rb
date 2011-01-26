require 'spec_helper'

describe MuTrumps::Web::Messaging do
  let(:app) do
    app = MuTrumps::Web::Messaging.new(:timeout => 2, :mount => "/")
    app.extend(ThinRunner)
    app
  end
  
  before(:all) { app.start(8000) }
  after(:all)  { app.stop }
  
  def connect
    endpoint  = URI.parse("http://localhost:8000/")
    channel   = "/games/#{game.id}/alice"
    
    handshake = '{"channel":"/meta/handshake","version":"1.0","supportedConnectionTypes":["long-polling"]}'
    response  = Net::HTTP.post_form(endpoint, "message" => handshake)
    client_id = JSON.parse(response.body)[0]["clientId"]
    
    subscribe = '{"channel":"/meta/subscribe","clientId":"' + client_id + '","subscription":"' + channel + '"}'
    response  = Net::HTTP.post_form(endpoint, "message" => subscribe)
    
    connect   = '{"channel":"/meta/connect","clientId":"' + client_id + '","connectionType":"long-polling"}'
    response  = Net::HTTP.post_form(endpoint, "message" => connect)
    
    JSON.parse(response.body).map { |m| m['data'] }.compact
  end
  
  let(:alice) { Factory :user, :lastfm_username => "alice" }
  let(:bob)   { Factory :user, :lastfm_username => "bob"   }
  let(:game)  { Factory :game }
  
  before do
    game.join(alice)
    game.join(bob)
  end
  
  describe "when no messages are sent" do
    it "receives no events" do
      connect.should == []
    end
    
    it "returns after the timeout" do
      lambda { connect }.should take(2)
    end
  end
  
  describe "when a message is sent" do
    before do
      EM.add_timer(1) { MuTrumps::Web::Messaging.publish(game, alice, "hello") }
    end
    
    it "receives an event" do
      connect.should == [{"event" => "hello"}]
    end
    
    it "returns when the message is sent" do
      lambda { connect }.should take(1..1.2)
    end
  end
end
