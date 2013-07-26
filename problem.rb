require 'json'

class Problem
  attr_reader :time, :flag, :problemset

  def self.parse(str)
    json = JSON.parse(str)
    Problem.new(json['time'].to_f, json['flag'], json['problemset'])
  end

  def self.load(path)
    self.parse(IO.read(path))
  end

  def initialize(time, flag, problemset)
    raise ArgumentError unless (time && time >= 0)
    raise ArgumentError unless (flag && !flag.empty?)
    raise ArgumentError unless (problemset && !problemset.empty?)
    @time = time
    @flag = flag
    @problemset = problemset
  end
end
