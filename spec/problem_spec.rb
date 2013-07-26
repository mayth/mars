$LOAD_PATH << __dir__
require './problem'

describe Problem do
  before do
    @problem = Problem.parse('{"time": "3.0", "flag": "FLAG_0123", "problemset": [{"in": "abc", "out": "zyx"}, {"in": "def", "out": "wvu"}]}')
  end

  describe '#time' do
    subject { @problem.time }
    context 'if successfully loaded' do
      it { should eq 3.0 }
    end
  end

  describe '#flag' do
    subject { @problem.flag }
    context 'if successfully loaded' do
      it { should eq 'FLAG_0123' }
    end
  end

  describe '#problemset' do
    subject { @problem.problemset }
    context 'if successfully loaded' do
      its(:empty?) { should be_false }
    end
  end
end
