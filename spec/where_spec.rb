require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable::Where do
  class TestEnumerable
    include ActiveEnumerable::Base
    include ActiveEnumerable::Where

    def custom_method
      :i_am_here!
    end
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

    context "#not" do
      it "returns results not matching conditions" do
        expect(TestEnumerable.new(item_hashes).where.not(name: "Fred").to_a).to eq [item_hashes[1], item_hashes[2]]
      end

      it "results is still of original type" do
        expect(TestEnumerable.new(item_hashes).where.not(name: "Fred").custom_method).to eq :i_am_here!
      end
    end

    context "#or(conditions)" do
      it "returns a uniq collection" do
        test_enum = TestEnumerable.new([{ paid: true, credit: 1000 }, { paid: false, credit: 2000 }, { paid: false, credit: 0 }])
        result    = test_enum.where(paid: false).or(credit: 0)
        expect(result.to_a).
            to eq [{ :paid => false, :credit => 2000 }, { :paid => false, :credit => 0 }]
      end

      it "with a where.not" do
        expect(TestEnumerable.new(item_hashes).where(name: "Dave").or(name: "Fred").where.not(name: "Sam").to_a).
            to eq [item_hashes[2], item_hashes[0]]
      end

      it "results is still of original type" do
        expect(TestEnumerable.new(item_hashes).where(name: "Dave").or(name: "Fred").where.not(name: "Sam").custom_method).to eq :i_am_here!
      end
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

