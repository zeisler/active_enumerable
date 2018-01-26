require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable do

  class TestEnumerable
    include ActiveEnumerable::Base
    include ActiveEnumerable::Scopes

    scope :freds, -> { to_a.select { |e| e[:name] == "Fred" } }
    scope :fred, -> { freds.to_a.first }
    scope :adults, -> { to_a.select { |e| e[:age] > 17 } }
  end

  let(:item_objects) { [OpenStruct.new(name: "Fred"), OpenStruct.new(name: "Dave")] }
  let(:item_hashes) { [{ name: "Fred" }, { name: "Sam" }, { name: "Dave" }] }

  describe ".scope" do
    it "creates a scoped query collection" do
      expect(TestEnumerable.new(item_objects).freds.to_a).to eq [item_objects.first]
    end

    context "allows chaining" do
      let(:item_hashes) { [{ name: "Fred" , age: 10 }, { name: "Fred", age: 23 }, { name: "Sam", age: 45 }, { name: "Dave", age: 54 }] }

      it do
        expect(TestEnumerable.new(item_hashes).freds.adults.to_a).to eq [item_hashes[1]]
      end
    end

    it "creates a scoped query collection" do
      expect(TestEnumerable.new(item_objects).fred).to eq item_objects.first
      expect(TestEnumerable.new(item_objects).respond_to?(:fred)).to eq true
    end
  end

  describe "#scope" do
    subject { TestEnumerable.new(item_hashes).scope { to_a.select { |e| e[:name] == "Sam" } } }

    it "creates a scoped query on the fly" do
      expect(subject.to_a).to eq [item_hashes[1]]
      expect(subject).to be_an_instance_of(TestEnumerable)
    end
  end

  it "method missing still works" do
    expect { TestEnumerable.new([]).this_method_will_never_be_defined }.to raise_error(NoMethodError)
  end

  it "respond to still works" do
    expect(TestEnumerable.new([]).respond_to?(:name)).to eq(true)
  end
end
