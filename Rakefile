require './lib/mu_trumps'

namespace :import do
  namespace :lastfm do
    task :top_artists, :username do |t, args|
      importer = MuTrumps::Importer::Lastfm.new(args.username)
      importer.logger { |s| puts s }
      importer.import_top_artists
    end
  end
  
  namespace :echonest do
    task :hotttnesss do
      MuTrumps::Artist.all.each do |artist|
        importer = MuTrumps::Importer::Echonest.new(artist)
        importer.import_hotttnesss
      end
    end
    
    task :familiarity do
      MuTrumps::Artist.all.each do |artist|
        importer = MuTrumps::Importer::Echonest.new(artist)
        importer.import_familiarity
      end
    end
  end

  namespace :seven_digital do
    task :ids do
      MuTrumps::Artist.all.each do |artist|
        importer = MuTrumps::Importer::SevenDigital.new(artist)
        importer.import_identifier
      end
    end
  end
end

namespace :db do
  task :setup do
    dir = File.expand_path(File.dirname(__FILE__))
    require dir + '/config/environment'
    require dir + '/config/schema'
  end
end
