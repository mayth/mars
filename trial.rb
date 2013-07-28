class Trial
  class WrongAnswer < Exception; end
  
  attr_reader :status, :freezed, :started_at, :finished_at

  def initialize(problem, socket)
    @freezed = false
    @problem = problem
    @status = :solving
    @socket = socket
  end

  def run
    @started_at = Time.now
    norma = @problem.problemset.size
    Thread.new(norma, @socket) do |norma, socket|
      begin
        while solving?
          @problem.problemset.each do |set|
            socket.puts set['in']
            ans = socket.readline.strip
            raise WrongAnswer if ans != set['out']
          end
          break
        end
      rescue WrongAnswer
        wrong!
      end
      if solving?
        solve!
      end
    end

    while solving?
      if (Time.now - @started_at) > @problem.time
        timeout!
      end
    end

    @finished_at = Time.now
  end

  def solving?
    @status == :solving
  end

  private

  def solve!
    unless @freezed
      @status = :solved
      @freezed = true
    end
  end

  def wrong!
    unless @freezed
      @status = :wrong
      @freezed = true
    end
  end

  def timeout!
    unless @freezed
      @status = :timeout
      @freezed = true
    end
  end
end
