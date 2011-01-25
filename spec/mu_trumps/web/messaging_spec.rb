require 'spec_helper'

RSpec::Matchers.define :take do |duration|
  match do |proc|
    begin
      start = Time.now
      proc.call
      diff = Time.now - start
      
      case duration
      when Numeric then diff >= duration
      when Range then diff >= duration.begin and diff < duration.end
      end
    rescue => e
      false
    end
  end
end

describe MuTrumps::Web::Messaging do
  let(:app) do
    app = MuTrumps::Web::Messaging.new(:timeout => 2)
    app.extend(ThinRunner)
    app
  end
  
  before(:all) { app.start(8000) }
  after(:all)  { app.stop }
  
  def connect
    uri = URI.parse("http://localhost:8000/alice")
    Net::HTTP.get_response(uri).body
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
      connect.should == "[]"
    end
    
    it "returns after the timeout" do
      lambda { connect }.should take(2)
    end
  end
  
  describe "when a message is sent" do
    before do
      EM.add_timer(1) { MuTrumps::Web::Messaging.publish(alice, "hello") }
    end
    
    it "receives an event" do
      connect.should == '[{"event":"hello"}]'
    end
    
    it "returns when the message is sent" do
      lambda { connect }.should take(1..1.2)
    end
  end
end
