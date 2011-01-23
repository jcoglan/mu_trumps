require 'uri'
require 'cgi'
require 'net/http'
require 'json'

module PopTrumps
  module Importer
    
    class Lastfm
      SERVICE_ROOT = 'http://ws.audioscrobbler.com/2.0/'
      
      def initialize(username)
        @username = username
      end
      
      def import_top_artists
        json = get_data('user.gettopartists', :user => @username)
        json['topartists']['artist'].each do |artist|
          artist = Artist.find_or_create_by_name(artist['name'])
          log("Imported #{artist.name}")
        end
      end
      
      def logger(&block)
        @logger = block
      end
      
    private
      
      def log(message)
        return unless @logger
        @logger.call(message)
      end
      
      def get_data(method, params = {})
        query_params = params.merge(
          :method  => method,
          :format  => 'json',
          :api_key => api_key)
        
        query    = query_params.map { |k,v| CGI.escape(k.to_s) + '='  +CGI.escape(v.to_s) }.join('&')
        uri      = URI.parse(SERVICE_ROOT + '?' + query)
        response = Net::HTTP.get_response(uri)
        
        JSON.parse(response.body)
      end
      
      def api_key
        Settings.lastfm.api_key
      end
    end
    
  end
end
