require './mars'

server = MarsServer.new('0.0.0.0', 9090)
server.async.run
sleep
