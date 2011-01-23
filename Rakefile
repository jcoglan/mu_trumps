require './lib/pop_trumps'

namespace :import do
  namespace :lastfm do
    task :top_artists, :username do |t, args|
      importer = PopTrumps::Importer::Lastfm.new(args.username)
      importer.logger { |s| puts s }
      importer.import_top_artists
    end
  end
end
