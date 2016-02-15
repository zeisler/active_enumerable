RSpec.describe ActiveEnumerable::EnglishDsl do

  class TestEnglishDsl
    include ActiveEnumerable::Base
    include ActiveEnumerable::EnglishDsl
  end

  subject { TestEnglishDsl.new(records) }

  describe "#where(&block)" do
    context "has(attr).of(single_match)" do
      let(:records) { [{ name: "Reuben" }, { name: "Naomi" }] }
      let(:result) { subject.where { has(:name).of("Reuben") } }
      it { expect(result).to be_an_instance_of TestEnglishDsl }
      it { expect(result.to_a).to eq [{ name: "Reuben" }] }
    end

    context "has(attr).of(matches)" do
      let(:records) { [
        { name: "Reuben", parents: [{ name: "Mom", age: 26 }, { name: "Dad", age: 33 }] },
        { name: "Naomi", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 33 }] }
      ] }
      let(:result) { subject.where { has(:parents).of(age: 29) } }
      it { expect(result).to be_an_instance_of TestEnglishDsl }
      it { expect(result.to_a).to eq [records.last] }
    end

    context "has(attr).of(matches).or(matches)" do
      let(:records) { [
        { name: "Reuben", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 33 }] },
        { name: "Naomi", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 41 }] }
      ] }
      let(:result) { subject.where { has(:parents).of(age: 29, name: "Mom").or(age: 33, name: "Dad") } }
      it { expect(result).to be_an_instance_of TestEnglishDsl }
      it { expect(result.to_a).to eq records}
    end

    context "has(attr).of(matches).and(matches)" do
      let(:records) { [
        { name: "Reuben", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 33 }] },
        { name: "Naomi", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 41 }] }
      ] }
      let(:result) { subject.where { has(:parents).of(age: 29, name: "Mom").and(age: 33, name: "Dad") } }
      it { expect(result).to be_an_instance_of TestEnglishDsl }
      it { expect(result.to_a).to eq [records.first] }
    end

    context "has(attr).of(matches).and.of(matches)" do
      let(:records) { [
        { name: "Reuben", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 33 }] },
        { name: "Naomi", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 41 }] }
      ] }
      let(:result) { subject.where { has(:parents).of(age: 29, name: "Mom").and.has(:name).of("Naomi") } }
      it { expect(result).to be_an_instance_of TestEnglishDsl }
      it { expect(result.to_a).to eq [records.last] }
    end

    context "#where still works" do
      let(:records) { [
        { name: "Reuben", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 33 }] },
        { name: "Naomi", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 41 }] }
      ] }
      let(:result) { subject.where(name: "Reuben") }
      it { expect(result).to be_an_instance_of TestEnglishDsl }
      it { expect(result.to_a).to eq [records.first] }
    end
  end
end
