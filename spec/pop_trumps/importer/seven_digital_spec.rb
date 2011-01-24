require 'spec_helper'

describe PopTrumps::Importer::SevenDigital do
  before do
    @imogen = Factory(:artist, :name => "Imogen Heap")
    @importer = PopTrumps::Importer::SevenDigital.new(@imogen)
  end

  describe "import_identifier" do
    it "adds the 7digital ID to the artist" do
      @importer.import_identifier
      @imogen.ids["7digital"].should == "8321"
    end
  end
end
