require 'spec_helper'

describe PopTrumps::Artist do
  let(:artist) do
    PopTrumps::Artist.new(:name => "Imogen Heap")
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
end
