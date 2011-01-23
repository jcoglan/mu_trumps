require 'active_record'

module PopTrumps
  ROOT = File.expand_path(File.dirname(__FILE__))
  
  autoload :Artist, ROOT + '/pop_trumps/model/artist'
  autoload :User,   ROOT + '/pop_trumps/model/user'
end