require 'uri'
require 'cgi'
require 'net/http'
require 'json'
require 'nokogiri'

module MuTrumps
  module Importer
    autoload :Echonest,     ROOT + '/mu_trumps/importer/echonest'
    autoload :Lastfm,       ROOT + '/mu_trumps/importer/lastfm'
    autoload :SevenDigital, ROOT + '/mu_trumps/importer/seven_digital'
  end
end
