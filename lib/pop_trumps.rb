module PopTrumps
  ROOT = File.expand_path(File.dirname(__FILE__))
  
  autoload :Artist,      ROOT + '/pop_trumps/model/artist'
  autoload :Card,        ROOT + '/pop_trumps/model/card'
  autoload :Game,        ROOT + '/pop_trumps/model/game'
  autoload :Statistic,   ROOT + '/pop_trumps/model/statistic'
  autoload :User,        ROOT + '/pop_trumps/model/user'
  
  autoload :Frontend,    ROOT + '/pop_trumps/frontend'
  autoload :Application, ROOT + '/pop_trumps/application'
  autoload :Messaging,   ROOT + '/pop_trumps/messaging'
  
  autoload :Importer,    ROOT + '/pop_trumps/importer'
  autoload :Settings,    ROOT + '/pop_trumps/settings'
end

require PopTrumps::ROOT + '/../config/environment'
