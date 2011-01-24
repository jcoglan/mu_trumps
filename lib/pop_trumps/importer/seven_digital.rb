module PopTrumps
  module Importer

    class SevenDigital
      SERVICE_ROOT = 'http://api.7digital.com/1.2/'

      def initialize(artist)
        @artist = artist
      end

      def import_identifier
        name     = CGI.escape(@artist.name)
        uri      = URI.parse("#{SERVICE_ROOT}artist/search?q=#{name}&oauth_consumer_key=#{api_key}&country=GB")
        response = Net::HTTP.get_response(uri)
        doc      = Nokogiri::XML(response.body)
        id       = doc.search('artist').first['id']

        @artist.identifiers << Identifier.new(:name => '7digital', :value => id)
      rescue
      end

      def api_key
        Settings.seven_digital.consumer_key
      end
    end

  end
end
