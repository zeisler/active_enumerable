require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable::Enumerable do
  class TestEnumerableBasic
    include ActiveEnumerable::Base
    include ActiveEnumerable::Enumerable
  end

  subject { TestEnumerableBasic.new([1,2,3]) }

  it { expect(subject).to be_a_kind_of Enumerable }

  it {expect(subject.map{|n| n*2}).to eq [2,4,6]}
end
