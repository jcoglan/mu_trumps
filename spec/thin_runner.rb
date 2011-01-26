module ThinRunner
  def start(port)
    handler = Rack::Handler.get('thin')
    Thread.new do
      handler.run(self, :Port => port) { |server| @http_server = server }
    end
    sleep 0.1 until EM.reactor_running?
  end
  
  def stop
    @http_server.stop if @http_server
    @http_server = nil
    sleep 0.1 while EM.reactor_running?
  end
end
