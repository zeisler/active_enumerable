require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable::Where do

  let(:item_objects) { [OpenStruct.new(name: "Fred"), OpenStruct.new(name: "Dave")] }
  let(:item_hashes) { [{ name: "Fred" }, { name: "Sam" }, { name: "Dave" }] }

  context "Active Enumerable's with the same collection are comparable" do
    context "with only base and comparable components" do
      class TestEnumerableBasic
        include ActiveEnumerable::Base
        include ActiveEnumerable::Comparable
      end

      it "with an array of object" do
        expect(TestEnumerableBasic.new(item_objects)).to eq TestEnumerableBasic.new(item_objects)
      end

      it "with an array of hashes" do
        expect(TestEnumerableBasic.new(item_hashes)).to eq TestEnumerableBasic.new(item_hashes)
      end
    end

    context "with all components" do
      class TestEnumerableFull
        include ActiveEnumerable
      end

      it "with an array of object" do
        expect(TestEnumerableFull.new(item_objects)).to eq TestEnumerableFull.new(item_objects)
      end

      it "with an array of hashes" do
        expect(TestEnumerableFull.new(item_hashes)).to eq TestEnumerableFull.new(item_hashes)
      end
    end
  end
end

