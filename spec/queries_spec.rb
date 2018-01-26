require "spec_helper"

RSpec.describe ActiveEnumerable::Queries do

  class QueriesTestEnumerable
    include ActiveEnumerable::Base
    include ActiveEnumerable::Queries
  end

  subject { QueriesTestEnumerable.new(records) }
  let(:records) { [{ id: 2, name: "Fred" }, { id: 4, name: "Sam" }, { id: 5, name: "Dave" }] }

  describe "#sum" do
    it "queries collection for object with name fred" do
      expect(subject.sum(:id)).to eq(11)
    end
  end

  describe "order" do
    context "single arg" do
      it { expect(subject.order(:name).to_a.map { |h| h[:name] }).to eq(%w(Dave Fred Sam)) }
    end

    context "more that one arg" do
      let(:records) { [{ age: 20, name: "Fred" }, { age: 29, name: "Fred" }, { age: 4, name: "Sam" }, { age: 5, name: "Dave" }] }
      it { expect(subject.order(:name, :age).to_a).to eq([{ :age => 5, :name => "Dave" }, { :age => 20, :name => "Fred" }, { :age => 29, :name => "Fred" }, { :age => 4, :name => "Sam" }]) }
    end

    context "directions with key args" do
      let(:records) { [{ age: 20, name: "Fred" }, { age: 29, name: "Fred" }, { age: 4, name: "Sam" }, { age: 5, name: "Dave" }] }
      it { expect(subject.order(:name, age: :desc).to_a).to eq([{ :age => 5, :name => "Dave" }, { :age => 29, :name => "Fred" }, { :age => 20, :name => "Fred" }, { :age => 4, :name => "Sam" }]) }
      it { expect(subject.order(:name, age: :asc).to_a).to eq([{ :age => 5, :name => "Dave" }, { :age => 20, :name => "Fred" }, { :age => 29, :name => "Fred" }, { :age => 4, :name => "Sam" }]) }
    end
  end

  describe "#find" do
    it { expect(subject.find(5)).to eq({ id: 5, name: "Dave" }) }
    it { expect(subject.find(2, 5).to_a).to eq [{ id: 2, name: "Fred" }, { id: 5, name: "Dave" }] }
    it { expect(subject.find([2, 5]).to_a).to eq [{ id: 2, name: "Fred" }, { id: 5, name: "Dave" }] }
    it { expect(subject.find([2]).to_a).to eq [{ id: 2, name: "Fred" }] }
    it { expect(subject.find([2])).to be_an_instance_of QueriesTestEnumerable }
    it { expect { subject.find(nil) }.to raise_error(ActiveEnumerable::RecordNotFound, "Couldn't find QueriesTestEnumerable without an ID") }
  end


  describe "#find_by" do
    it "queries collection for object with name fred" do
      expect(subject.find_by(name: "Fred")).to eq({ id: 2, name: "Fred" })
    end
  end

  describe "#find_by!" do
    context "when records is not found" do
      it "raises an record not found error" do
        expect { subject.find_by!(name: "Tim") }.to raise_error(ActiveEnumerable::RecordNotFound)
      end
    end

    it "queries collection for object with name fred" do
      expect(subject.find_by!(name: "Fred")).to eq({ id: 2, name: "Fred" })
    end
  end

  describe "#count" do
    it "returns a count of all records" do
      expect(subject.count).to eq(3)
    end

    it "returns the total count of all people whose age is not nil" do
      expect(subject.count(:name)).to eq(3)
    end
  end

  describe "#limit" do
    it "specifies a limit for the number of records to retrieve" do
      expect(subject.limit(2)).to be_an_instance_of(QueriesTestEnumerable)
      expect(subject.limit(2).count).to eq(2)
    end
  end

  describe "#average" do
    it "calculates the average value on a given attribute" do
      expect(subject.average(:id).round(2)).to eq(3.67)
    end

    it "returns nil if there's no object" do
      expect(subject.limit(0).average(:id)).to eq(nil)
    end
  end

  describe "#minimum" do
    it "calculates the minimum value on a given attribute" do
      expect(subject.minimum(:id)).to eq(2)
    end

    it "returns nil if there's no object" do
      expect(subject.limit(0).minimum(:id)).to eq(nil)
    end
  end

  describe "#maximum" do
    it "calculates the maximum value on a given attribute" do
      expect(subject.maximum(:id)).to eq(5)
    end

    it "returns nil if there's no object" do
      expect(subject.limit(0).maximum(:id)).to eq(nil)
    end
  end

  describe "#reverse_order" do
    it "reverses the existing order clause on the relation" do
      expect(subject.reverse_order.to_a).to eq([{ :id => 5, :name => "Dave" }, { :id => 4, :name => "Sam" }, { :id => 2, :name => "Fred" }])
    end
  end

  describe "#none" do
    it "returns a chainable relation with zero records" do
      expect(subject.none).to be_an_instance_of(QueriesTestEnumerable)
      expect(subject.none.count).to eq(0)
    end
  end
end
