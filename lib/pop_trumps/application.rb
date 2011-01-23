require 'sinatra'

module PopTrumps
  class Application < Sinatra::Base
    
    helpers do
      def return_json(hash)
        headers 'Content-Type' => 'application/json'
        JSON.dump(hash)
      end
    end
    
    get '/artists/:id.json' do
      artist = Artist.find(params[:id])
      return_json('id'    => artist.id,
                  'name'  => artist.name,
                  'stats' => artist.stats)
    end
    
  end
end
