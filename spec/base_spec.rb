require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable::Base do

  class TestActiveEnumerable
    include ActiveEnumerable::Base
  end

  describe "initialize" do
    it "raise an error if type not array" do
      expect{TestActiveEnumerable.new(1)}.to raise_error(NoMethodError, "undefined method `to_ary' for 1:Fixnum")
    end
  end

  describe "#to_a" do
    it "returns the array passed to the initializer" do
      passed_array = [1,2,4]
      expect(TestActiveEnumerable.new(passed_array).to_a).to eq passed_array
    end
  end

  describe "#__new_relation__" do
    it "alias method to self.class.new" do
      expect(TestActiveEnumerable.new([]).__new_relation__([1,2]).to_a).to eq [1,2]
    end
  end

  describe "#create" do
    it "by default is creates a new hash from passed attributes and adds to collection" do
      subject = TestActiveEnumerable.new
      subject.create(name: "Jane", age: 23)
      expect(subject.to_a).to eq [{:name=>"Jane", :age=>23}]
    end

    context "override hash item type" do
      after { TestActiveEnumerable.item_class = nil }

      it "with item type of OpenStruct" do
        TestActiveEnumerable.item_class = OpenStruct
        subject = TestActiveEnumerable.new
        subject.create(name: "Jane", age: 23)
        expect(subject.to_a).to eq [OpenStruct.new(:name=>"Jane", :age=>23)]
      end
    end
  end

  describe "#add" do
    it "adds an item to the collection" do
      subject = TestActiveEnumerable.new
      subject.add(name: "Naomi", age: 4)
      expect(subject.to_a).to eq [{name: "Naomi", age: 4}]
    end
  end

  describe "#all" do
    it "returns it's self" do
      subject = TestActiveEnumerable.new
      expect(subject.all).to eq subject
    end
  end
end
