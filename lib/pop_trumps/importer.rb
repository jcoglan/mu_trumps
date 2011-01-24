require 'uri'
require 'cgi'
require 'net/http'
require 'json'

module PopTrumps
  module Importer
    autoload :Echonest, ROOT + '/pop_trumps/importer/echonest'
    autoload :Lastfm,   ROOT + '/pop_trumps/importer/lastfm'
  end
end
