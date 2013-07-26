require 'logger'
require 'celluloid/io'

class MarsServer
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port, log_out: STDOUT)
    @logger = ::Logger.new(log_out)
    @logger.progname = 'Mars'
    @logger.info "Starting up Mars server listening at #{host}:#{port}"
    @server = TCPServer.new(host, port)
  end

  def shutdown
    @server.close if @server
  end

  def run
    until @stop
      async.handle_connection @server.accept
    end
  end

  def stop
    @stop = true
  end

  def handle_connection(socket)
    _, port, host = socket.peeraddr
    @logger.info "Connect from #{host}:#{port}"
    loop { socket.write socket.readline }
  rescue EOFError
    @logger.info "Connection Closed from #{host}:#{port}"
    socket.close
  end
end
