module MuTrumps
  ROOT = File.expand_path(File.dirname(__FILE__))
  
  autoload :Artist,      ROOT + '/mu_trumps/model/artist'
  autoload :Card,        ROOT + '/mu_trumps/model/card'
  autoload :Game,        ROOT + '/mu_trumps/model/game'
  autoload :Identifier,  ROOT + '/mu_trumps/model/identifier'
  autoload :Statistic,   ROOT + '/mu_trumps/model/statistic'
  autoload :User,        ROOT + '/mu_trumps/model/user'
  
  autoload :Web,         ROOT + '/mu_trumps/web'
  
  autoload :Importer,    ROOT + '/mu_trumps/importer'
  autoload :Settings,    ROOT + '/mu_trumps/settings'
end

require MuTrumps::ROOT + '/../config/environment'
