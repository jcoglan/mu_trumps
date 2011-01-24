module PopTrumps
  module Web
    
    class Frontend < Rack::URLMap
      def initialize(map = {})
        @application = Application.new
        @messaging   = Messaging.new(:timeout => 25)
        
        super('/messaging' => @messaging,
              '/'          => @application)
      end
    end
    
  end
end
