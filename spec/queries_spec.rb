require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable do

  class TestEnumerable
    include ActiveEnumerable

    scope :freds, -> { select { |e| e.name == "Fred" } }
    scope :fred, -> { find_by(name: "Fred") }
  end

  class OtherEnumerable
    include ActiveEnumerable
  end

  let(:item_objects) { [OpenStruct.new(name: "Fred"), OpenStruct.new(name: "Dave")] }
  let(:item_hashes) { [{ name: "Fred" }, { name: "Sam" }, { name: "Dave" }] }

  describe ".scope" do

    it "creates a scoped query collection" do
      expect(TestEnumerable.new(item_objects).freds).to eq TestEnumerable.new([item_objects.first])
    end

    it "creates a scoped query collection" do
      expect(TestEnumerable.new(item_objects).fred).to eq item_objects.first
    end
  end

  describe "#where" do

    it "queries collection for object with name fred" do
      expect(TestEnumerable.new(item_objects).where(name: "Fred")).to eq TestEnumerable.new([item_objects.first])
    end

    it "queries collection for hashes with the key name and value fred" do
      expect(TestEnumerable.new(item_hashes).where(name: "Fred")).to eq TestEnumerable.new([item_hashes.first])
    end

    it "where not" do
      expect(TestEnumerable.new(item_hashes).where.not(name: "Fred")).to eq TestEnumerable.new([item_hashes[1],item_hashes[2]])
    end

    it "where or conditions" do
      expect(TestEnumerable.new(item_hashes).where(name: "Dave").or(name: "Fred").where.not(name: "Sam")).
        to eq TestEnumerable.new([item_hashes[2],item_hashes[0]])
    end

    it "where or relation" do
      te = TestEnumerable.new(item_hashes)
      expect(te.where(name: "Dave").or(te.where(name: "Fred")).where.not(name: "Sam")).
        to eq TestEnumerable.new([item_hashes[2],item_hashes[0]])
    end
  end

  describe "#find_by" do

    it "queries collection for object with name fred" do
      expect(TestEnumerable.new(item_objects).find_by(name: "Fred")).to eq item_objects.first
    end

    it "queries collection for hashes with the key name and value fred" do
      expect(TestEnumerable.new(item_hashes).find_by(name: "Fred")).to eq item_hashes.first
    end
  end

  context "comparable" do
    it "Objects of the same type and collection are equal" do
      expect(TestEnumerable.new(item_objects)).to eq TestEnumerable.new(item_objects)
    end

    it "Objects of different types and same collection are not equal" do
      expect(TestEnumerable.new(item_objects)).to_not eq OtherEnumerable.new(item_objects)
    end

    it "An ActiveEnumerable collection is equal to an array with the same item_objects" do
      expect(TestEnumerable.new(item_objects)).to eq item_objects
    end
  end
end
