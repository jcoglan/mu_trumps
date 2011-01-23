require 'spec_helper'

describe PopTrumps::User do
  let(:user) do
    PopTrumps::User.create(:lastfm_username => "jcoglan")
  end
  
  it "is valid" do
    user.should be_valid
  end
  
  describe "with artists" do
    before do
      @artist = Factory(:artist)
      user.artists << @artist
    end
    
    it "returns the artists" do
      user.reload.artists.should == [@artist]
    end
  end
end
