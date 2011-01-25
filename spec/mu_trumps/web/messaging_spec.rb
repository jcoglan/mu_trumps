require 'spec_helper'

describe MuTrumps::Web::Messaging do
  let(:app) do
    app = MuTrumps::Web::Messaging.new(:timeout => 2)
    app.extend(ThinRunner)
    app
  end
  
  before(:all) { app.start(8000) }
  after(:all)  { app.stop }
  
  def get(path)
    uri = URI.parse('http://localhost:8000' + path)
    Net::HTTP.get_response(uri)
  end
  
  let(:alice) { Factory :user, :lastfm_username => "alice" }
  let(:bob)   { Factory :user, :lastfm_username => "bob"   }
  let(:game)  { Factory :game }
  
  before do
    game.join(alice)
    game.join(bob)
  end
  
  it "receives no events after a timeout" do
    time = Time.now
    response = get "/alice"
    response.body.should == "[]"
    (Time.now - time).should >= 2
  end
  
  it "receives an event when it is published" do
    EM.add_timer(1) { MuTrumps::Web::Messaging.publish(alice, "hello") }
    time = Time.now
    response = get "/alice"
    response.body.should == '[{"event":"hello"}]'
    (Time.now - time).should be_between(1,2)
  end
end
