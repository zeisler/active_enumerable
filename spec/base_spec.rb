require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable::Base do

  class BaseTestActiveEnumerable
    include ActiveEnumerable::Base
    def initialize(collection=[])
      active_enumerable_setup(collection)
    end
  end

  describe "initialize" do
    it "raise an error if type not array" do
      expect { BaseTestActiveEnumerable.new(1) }.to raise_error(NoMethodError)
    end
  end

  describe "#to_a" do
    it "returns the array passed to the initializer" do
      passed_array = [1, 2, 4]
      expect(BaseTestActiveEnumerable.new(passed_array).to_a).to eq passed_array
    end
  end

  describe "#__new_relation__" do
    it "alias method to self.class.new" do
      expect(BaseTestActiveEnumerable.new([]).__new_relation__([1, 2]).to_a).to eq [1, 2]
    end
  end

  describe "#add" do
    it "adds an item to the collection" do
      subject = BaseTestActiveEnumerable.new
      subject.add(name: "Naomi", age: 4)
      expect(subject.to_a).to eq [{ name: "Naomi", age: 4 }]
    end

    it "works the same as :<<" do
      subject = BaseTestActiveEnumerable.new
      subject << { name: "Naomi", age: 4 }
      expect(subject.to_a).to eq [{ name: "Naomi", age: 4 }]
    end
  end

  describe "#all" do
    it "returns it's self" do
      subject = BaseTestActiveEnumerable.new
      expect(subject.all).to eq subject
    end
  end
end
