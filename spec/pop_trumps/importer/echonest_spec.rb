require 'spec_helper'

describe PopTrumps::Importer::Echonest do
  before do
    @imogen = Factory(:artist, :name => "Imogen Heap")
    @importer = PopTrumps::Importer::Echonest.new(@imogen)
  end
  
  describe "import_hotttnesss" do
    it "imports the hotttnesss for all artists" do
      @importer.import_hotttnesss
      @imogen.stats["hotttnesss"].should == 0.518605607525262
    end
  end
  
  describe "import_familiarity" do
    it "imports the familiarity for all artists" do
      @importer.import_familiarity
      @imogen.stats["familiarity"].should == 0.81634935777606032
    end
  end
end
