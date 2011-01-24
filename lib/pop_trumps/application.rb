require 'sinatra'
require 'json'

module PopTrumps
  class Application < Sinatra::Base
    
    helpers do
      def cards_for_user(game, user)
        game.cards_for(user).map do |card|
          {'id' => card.artist.id, 'name' => card.artist.name, 'image' => card.artist.image_url}
        end
      end
      
      def notify_current_user(game)
        game.users.each do |user|
          Messaging.publish(user, 'current_user', 'username' => game.current_user.lastfm_username)
        end
      end
      
      def return_json(hash)
        headers 'Content-Type' => 'application/json'
        JSON.dump(hash)
      end
    end
    
    error do
      return_json('status' => 'error')
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
      
      if game.users.size == 2
        Messaging.publish(game.users.first, "start")
        notify_current_user(game)
      end
      
      return_json('status' => game.status,
                  'id'     => game.id,
                  'cards'  => cards_for_user(game, user))
    end
    
    get '/games/:id.json' do
      game   = Game.find(params[:id])
      scores = game.users.map { |u| [u.lastfm_username, game.cards_for(u).size] }
      
      return_json('status'       => game.status,
                  'id'           => game.id,
                  'current_user' => game.current_user.lastfm_username,
                  'users'        => Hash[scores])
    end
    
    get '/games/:id/cards/:username.json' do
      game = Game.find(params[:id])
      user = User.find_by_lastfm_username(params[:username])
      return_json(cards_for_user(game, user))
    end
    
    post '/games/:id/plays.json' do
      begin
        game   = Game.find(params[:id])
        user   = User.find_by_lastfm_username(params[:username])
        artist = Artist.find(params[:artist_id])
        stat   = params[:stat]
        
        game.play(user, artist, stat)
        
        Messaging.publish(game.waiting_user, 'play',
                          'username' => user.lastfm_username,
                          'stat'     => stat,
                          'value'    => artist.stats[stat])
        
        return_json('status' => 'ok')
      rescue
        return_json('status' => 'error')
      end
    end
    
    post '/games/:id/ack.json' do
      begin
        game = Game.find(params[:id])
        user = User.find_by_lastfm_username(params[:username])
        
        game.ack(user)
        
        Messaging.publish(game.current_user, 'result', 'result' => 'win')
        Messaging.publish(game.waiting_user, 'result', 'result' => 'lose')
        
        [game.current_user, game.waiting_user].each do |user|
          Messaging.publish(user, 'cards', 'cards' => cards_for_user(game, user))
        end
        
        if winner = game.winner
          game.users.each do |user|
            Messaging.publish(user, 'winner', 'username' => winner.lastfm_username)
          end
        else
          notify_current_user(game)
        end
        
        return_json('status' => 'ok')
      rescue
        return_json('status' => 'error')
      end
    end
    
    get '/poke/:username/:event' do
      user = User.find_by_lastfm_username(params[:username])
      Messaging.publish(user, params[:event])
      return_json('status' => 'ok')
    end
    
  end
end
