module PopTrumps
  module Importer
    
    class Echonest
      SERVICE_ROOT = 'http://developer.echonest.com/api/v4/'
      
      def initialize(artist)
        @artist = artist
      end
      
      def import_hotttnesss
        uri = URI.parse("#{SERVICE_ROOT}artist/hotttnesss?api_key=#{api_key}&id=#{artist_id}&format=json")
        response = Net::HTTP.get_response(uri)
        value = JSON.parse(response.body)['response']['artist']['hotttnesss']
        @artist.assign('hotttnesss', value)
      rescue
      end
      
      def import_familiarity
        uri = URI.parse("#{SERVICE_ROOT}artist/familiarity?api_key=#{api_key}&id=#{artist_id}&format=json")
        response = Net::HTTP.get_response(uri)
        value = JSON.parse(response.body)['response']['artist']['familiarity']
        @artist.assign('familiarity', value)
      rescue
      end
      
      def artist_id
        return @artist_id if defined?(@artist_id)
        
        uri = URI.parse("#{SERVICE_ROOT}artist/search?api_key=#{api_key}&format=json&name=#{CGI.escape @artist.name}")
        response = Net::HTTP.get_response(uri)
        @artist_id = JSON.parse(response.body)['response']['artists'].first['id']
      end
      
      def api_key
        Settings.echonest.api_key
      end
    end
    
  end
end
