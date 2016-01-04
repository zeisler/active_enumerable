require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable::Where do
  class TestEnumerable
    include ActiveEnumerable::Base
    include ActiveEnumerable::Enumerable
    include ActiveEnumerable::Where
  end

  let(:item_objects) { [OpenStruct.new(name: "Fred"), OpenStruct.new(name: "Dave")] }
  let(:item_hashes) { [{ name: "Fred" }, { name: "Sam" }, { name: "Dave" }] }

  describe "#where" do

    it "queries collection for object with `name` =='fred'" do
      expect(TestEnumerable.new(item_objects).where(name: "Fred").to_a).to eq [item_objects.first]
    end

    it "queries collection for hashes with the key of :name and value of 'fred'" do
      expect(TestEnumerable.new(item_hashes).where(name: "Fred").to_a).to eq [item_hashes.first]
    end

    it "#not" do
      expect(TestEnumerable.new(item_hashes).where.not(name: "Fred").to_a).to eq [item_hashes[1], item_hashes[2]]
    end

    it "#or(conditions)" do
      expect(TestEnumerable.new(item_hashes).where(name: "Dave").or(name: "Fred").where.not(name: "Sam").to_a).
        to eq [item_hashes[2], item_hashes[0]]
    end

    it "#or(<#ActiveEnumerable>)" do
      subject = TestEnumerable.new(item_hashes)
      expect(subject.where(name: "Dave").or(subject.where(name: "Fred")).where.not(name: "Sam").to_a).
        to eq [item_hashes[2], item_hashes[0]]
    end

    it "nested with array" do
      items   = [{ name: "Richard", accounts: [{ balance: 200 }] }]
      subject = TestEnumerable.new(items)
      expect(subject.where(accounts: { balance: 200 }).to_a).to eq items
    end

    it "nested objects" do
      items   = [{ name: "Richard", account: { balance: 200 } }]
      subject = TestEnumerable.new(items)
      expect(subject.where(account: { balance: 200 }).to_a).to eq items
    end
  end
end

