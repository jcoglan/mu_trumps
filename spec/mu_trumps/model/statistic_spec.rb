require 'spec_helper'

describe MuTrumps::Statistic do
  let(:artist) { Factory(:artist) }
  
  let(:statistic) do
    MuTrumps::Statistic.create(:artist => artist,
                                :name   => "releases",
                                :value  => 6)
  end
  
  it "is valid" do
    statistic.should be_valid
  end
  
  describe "without an artist" do
    before { statistic.artist = nil }
    
    it "is not valid" do
      statistic.should_not be_valid
    end
  end
  
  describe "without a name" do
    before { statistic.name = nil }
    
    it "is not valid" do
      statistic.should_not be_valid
    end
  end
  
  describe "without a value" do
    before { statistic.value = nil }
    
    it "is not valid" do
      statistic.should_not be_valid
    end
  end
  
  describe "with the same name as another stat for the same artist" do
    let(:bad_stat) do
      MuTrumps::Statistic.new(:artist => artist,
                               :name   => "releases",
                               :value  => 6)
    end
    
    it "is not valid" do
      bad_stat.artist.should == statistic.artist
      bad_stat.name.should == statistic.name
      bad_stat.should_not be_valid
    end
  end
end
