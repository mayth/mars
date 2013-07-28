require 'logger'
require 'celluloid/io'
require './problem'
require './trial'

class MarsServer
  include Celluloid::IO
  finalizer :shutdown

  class Timeout < RuntimeError; end
  class ProblemIDError < RuntimeError; end
  class ProblemNotfoundError < RuntimeError; end

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
    problem_id = get_problem_id(socket)
    @logger.info "#{host}:#{port} tries #{problem_id}"
    try(socket, problem_id)
  rescue ProblemIDError => e
    @logger.info "Invalid format of Problem ID: #{e.message}"
    socket.puts 'Unacceptable Format of Problem Name'
  rescue ProblemNotfoundError => e
    @logger.info "Problem #{e.message} Not Found"
    socket.puts 'Problem Unavailable.'
  rescue Timeout
    @logger.info "Connection from #{host}:#{port} is closing because of timeout"
  rescue EOFError
    @logger.info 'Connection is being closed by client'
  ensure
    @logger.info "Connection from #{host}:#{port} closed"
    socket.close
  end

  def get_problem_id(socket)
    id = ""
    t = Thread.new(id) do |id|
      id << socket.readline.strip
    end
    raise Timeout unless t.join(3)
    raise ProblemIDError, id unless id =~ /^[0-9a-zA-Z_-]+$/
    id
  end

  def try(socket, problem_id)
    problem_file = "problems/#{problem_id}.json"
    raise ProblemNotfoundError, problem_id unless File.exist? problem_file
    @logger.info "#{problem_file} loaded."
    problem = Problem.load(problem_file)
    trial = Trial.new(problem, socket)
    trial.run
    case trial.status
    when :solved
      socket.puts "Congratulation! Flag=#{problem.flag}"
    when :timeout
      socket.puts 'Timed out.'
    when :wrong
      socket.puts 'Wrong Answer.'
    else
      socket.puts 'Failed. Try Again!'
    end
  end
end
