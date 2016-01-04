require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable do

  class TestEnumerable
    include ActiveEnumerable::Base
    include ActiveEnumerable::Scopes

    scope :freds, -> { to_a.select { |e| e.name == "Fred" } }
    scope :fred, -> { freds.to_a.first }
  end

  class OtherEnumerable
    include ActiveEnumerable
  end

  let(:item_objects) { [OpenStruct.new(name: "Fred"), OpenStruct.new(name: "Dave")] }
  let(:item_hashes) { [{ name: "Fred" }, { name: "Sam" }, { name: "Dave" }] }

  describe ".scope" do

    it "creates a scoped query collection" do
      expect(TestEnumerable.new(item_objects).freds.to_a).to eq [item_objects.first]
    end

    it "creates a scoped query collection" do
      expect(TestEnumerable.new(item_objects).fred).to eq item_objects.first
    end
  end

  describe "#scope" do
    subject { TestEnumerable.new(item_hashes).scope { to_a.select { |e| e[:name] == "Sam" } } }

    it "creates a scoped query on the fly" do
      expect(subject.to_a).to eq [item_hashes[1]]
      expect(subject).to be_an_instance_of(TestEnumerable)
    end
  end
end
