require 'spec_helper'

describe MuTrumps::Importer::Lastfm do
  let(:importer) { MuTrumps::Importer::Lastfm.new("jcoglan") }
  
  describe "import_top_artists" do
    let(:import) { importer.import_top_artists }
    
    it "creates artists" do
      import
      MuTrumps::Artist.all.map(&:name).should == [
        "Iron & Wine",
        "The Magnetic Fields",
        "School of Seven Bells"
      ]
    end
  end
end
