module ThinRunner
  def start(port)
    handler = Rack::Handler.get('thin')
    Thread.new do
      handler.run(self, :Port => port) { |server| @server = server }
    end
    sleep 0.1 until EM.reactor_running?
  end
  
  def stop
    @server.stop if @server
    @server = nil
    sleep 0.1 while EM.reactor_running?
  end
end
