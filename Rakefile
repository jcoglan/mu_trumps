require './lib/pop_trumps'

namespace :import do
  namespace :lastfm do
    task :top_artists, :username do |t, args|
      importer = PopTrumps::Importer::Lastfm.new(args.username)
      importer.logger { |s| puts s }
      importer.import_top_artists
    end
  end
  
  namespace :echonest do
    task :hotttnesss do
      PopTrumps::Artist.all.each do |artist|
        importer = PopTrumps::Importer::Echonest.new(artist)
        importer.import_hotttnesss
      end
    end
    
    task :familiarity do
      PopTrumps::Artist.all.each do |artist|
        importer = PopTrumps::Importer::Echonest.new(artist)
        importer.import_familiarity
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
