require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable::Base do

  class BaseTestActiveEnumerable
    include ActiveEnumerable::Base
  end

  describe "initialize" do
    it "raise an error if type not array" do
      expect { BaseTestActiveEnumerable.new(1) }.to raise_error(NoMethodError, "undefined method `to_a' for 1:Fixnum")
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

  describe "#create" do
    it "by default is creates a new hash from passed attributes and adds to collection" do
      subject = BaseTestActiveEnumerable.new
      subject.create(name: "Jane", age: 23)
      expect(subject.to_a).to eq [{ :name => "Jane", :age => 23 }]
    end

    context "override hash item type" do
      after { BaseTestActiveEnumerable.item_class = nil }

      it "with item type of OpenStruct" do
        BaseTestActiveEnumerable.item_class = OpenStruct
        subject            = BaseTestActiveEnumerable.new
        subject.create(name: "Jane", age: 23)
        expect(subject.to_a).to eq [OpenStruct.new(:name => "Jane", :age => 23)]
      end
    end
  end

  describe "#add" do
    it "adds an item to the collection" do
      subject = BaseTestActiveEnumerable.new
      subject.add(name: "Naomi", age: 4)
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
