require 'spec_helper'

describe MuTrumps::Artist do
  let(:artist) do
    MuTrumps::Artist.create(:name => "Imogen Heap")
  end
  
  it "is valid" do
    artist.should be_valid
  end
  
  describe "without a name" do
    before { artist.name = nil }
    
    it "is not valid" do
      artist.should_not be_valid
    end
  end
  
  describe "stats" do
    before do
      artist.statistics << MuTrumps::Statistic.new(:name => "releases", "value" => 12)
      artist.statistics << MuTrumps::Statistic.new(:name => "concerts", "value" => 950)
    end
    
    it "returns the statictics as a hash" do
      artist.stats.should == {"releases" => 12, "concerts" => 950}
    end
  end
  
  describe "assign" do
    it "adds a statistic to the artist" do
      artist.assign("releases", 9)
      artist.stats["releases"].should == 9
    end
    
    it "modifies an existing statistic" do
      artist.assign("releases", 2)
      artist.assign("releases", 4)
      artist.statistics.should == [MuTrumps::Statistic.first]
      artist.stats.should == {"releases" => 4}
    end
  end
end
