require 'sinatra'

module PopTrumps
  class Application < Sinatra::Base
    
    helpers do
      def game_status(game)
        case game.users.count
        when 1 then 'waiting'
        when 2 then 'ready'
        end
      end
      
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
    
    post '/users/register.json' do
      user = User.find_or_create_by_lastfm_username(params[:username])
      return_json('id' => user.id, 'username' => user.lastfm_username)
    end
    
    post '/games.json' do
      user  = User.find_by_lastfm_username(params[:username])
      game  = Game.join(user)
      cards = game.cards_for(user).map do |card|
        {'id' => card.artist.id, 'name' => card.artist.name}
      end
      return_json('status' => game_status(game), 'cards' => cards)
    end
    
  end
end
