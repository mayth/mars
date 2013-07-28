$LOAD_PATH << __dir__
require './problem'
require './trial'

describe Trial do
  before do
    @problem = Problem.parse('{"time": "3.0", "flag": "FLAG_0123", "problemset": [{"in": "abc", "out": "zyx"}, {"in": "def", "out": "wvu"}]}')
    @trial = Trial.new(@problem, STDOUT)
  end

  describe '#freezed' do
    subject { @trial.freezed }
    context 'after initialize' do
      it { should be_false }
    end
    context 'after solved' do
      before { @trial.send(:solve!) }
      it { should be_true }
    end
    context 'after timed out' do
      before { @trial.send(:timeout!) }
      it { should be_true }
    end
    context 'after wrong answer' do
      before { @trial.send(:wrong!) }
      it { should be_true }
    end
  end

  describe '#solving?' do
    subject { @trial.solving? }
    context 'after initialize' do
      it { should be_true }
    end
    context 'after solved' do
      before { @trial.send(:solve!) }
      it { should be_false }
    end
    context 'after timed out' do
      before { @trial.send(:timeout!) }
      it { should be_false }
    end
    context 'after wrong answer' do
      before { @trial.send(:wrong!) }
      it { should be_false }
    end
  end

  describe '#solve!' do
    before { @trial.send(:solve!) }
    subject { @trial.status }
    context 'after initialize' do
      it { should eq :solved }
    end
    context 'after timed out' do
      before { @trial.send(:timeout!) }
      it { should eq :solved }
    end
    context 'after wrong answer' do
      before { @trial.send(:wrong!) }
      it { should eq :solved }
    end
  end
end
