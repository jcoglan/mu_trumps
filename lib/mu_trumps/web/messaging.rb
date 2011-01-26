require 'faye'

module MuTrumps
  module Web
    
    class Messaging < Faye::RackAdapter
      def self.new(*args)
        @instance = super(*args)
      end
      
      def self.publish(*args)
        return unless @instance
        @instance.publish(*args)
      end
      
      def publish(game, user, event, params = {})
        channel = "/games/#{game.id}/#{user.lastfm_username}"
        message = params.merge('event' => event)
        get_client.publish(channel, message)
      end
    end
    
  end
end
