require 'spec_helper'

describe PopTrumps::Card do
  let(:card) do
    PopTrumps::Card.create(:game   => Factory(:game),
                           :artist => Factory(:artist))
  end
  
  it "is valid" do
    card.should be_valid
  end
  
  describe "without a game" do
    before { card.game = nil }
    
    it "is not valid" do
      card.should_not be_valid
    end
  end
  
  describe "without an artist" do
    before { card.artist = nil }
    
    it "is not valid" do
      card.should_not be_valid
    end
  end
end
