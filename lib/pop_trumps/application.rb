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
      user = User[params[:username]]
      return_json('id' => user.id, 'username' => user.lastfm_username)
    end
    
    post '/games.json' do
      user  = User[params[:username]]
      game  = Game.join(user)
      cards = game.cards_for(user).map do |card|
        {'id' => card.artist.id, 'name' => card.artist.name}
      end
      return_json('status' => game_status(game),
                  'id'     => game.id,
                  'cards'  => cards)
    end
    
    get '/games/:id.json' do
      game   = Game.find(params[:id])
      scores = game.users.map { |u| [u.lastfm_username, game.cards_for(u).size] }
      
      return_json('status'       => game_status(game),
                  'id'           => game.id,
                  'current_user' => game.current_user.lastfm_username,
                  'users' => Hash[scores])
    end
    
  end
end
