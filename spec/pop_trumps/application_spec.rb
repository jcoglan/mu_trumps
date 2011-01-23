require 'capybara/dsl'
require 'spec_helper'

describe PopTrumps::Application do
  include Capybara
  
  before do
    Capybara.default_driver = :rack_test
    Capybara.app = PopTrumps::Application.new
  end
  
  describe "/artists/:id" do
    before do
      artist = Factory(:artist, :id => 100, :name => "Imogen Heap")
      artist.assign("releases", 23)
      artist.assign("concerts", 1024)
    end
    
    it "returns details for an artist" do
      visit "/artists/100.json"
      JSON.parse(body).should == {
        "id"    => 100,
        "name"  => "Imogen Heap",
        "stats" => {
          "releases" => 23,
          "concerts" => 1024
        }
      }
    end
  end
end