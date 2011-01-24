require 'uri'
require 'cgi'
require 'net/http'
require 'json'
require 'nokogiri'

module PopTrumps
  module Importer
    autoload :Echonest,     ROOT + '/pop_trumps/importer/echonest'
    autoload :Lastfm,       ROOT + '/pop_trumps/importer/lastfm'
    autoload :SevenDigital, ROOT + '/pop_trumps/importer/seven_digital'
  end
end
