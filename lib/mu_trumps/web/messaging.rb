require 'eventmachine'

module MuTrumps
  module Web
    
    class Messaging
      TYPE_JSON = {'Content-Type' => 'application/json'}
      
      def self.new(*args)
        @instance = super(*args)
      end
      
      def self.publish(user, event, params = {})
        return unless @instance
        @instance.publish(user, event, params)
      end
      
      def initialize(options = {})
        @options     = options
        @channels    = {}
        @connections = {}
      end
      
      def publish(user, event, params = {})
        username = user.lastfm_username
        message  = params.merge('event' => event)
        
        @channels[username] ||= []
        @channels[username].push(message)
        
        flush(username)
      end
      
      def call(env)
        request  = Rack::Request.new(env)
        username = request.path_info.split('/')[1]
        response = Response.new
        
        callback = env['async.callback']
        callback.call [200, TYPE_JSON, response]
        
        @connections[username] = response
        flush(username)
        
        EM.add_timer(@options[:timeout]) do
          @connections.delete(username) if response.succeed([])
        end
        
        [-1, {}, []]
      end
      
      private
      
      def flush(username)
        return unless @channels.has_key?(username) and
        @connections.has_key?(username)
        
        events = @channels.delete(username)
        @connections.delete(username).succeed(events)
      end
      
      class Response
        include EM::Deferrable
        alias :each :callback
        
        def succeed(events)
          return false if @succeeded
          json = JSON.dump(events)
          super(json)
          @succeeded = true
        end
      end
    end
    
  end
end
