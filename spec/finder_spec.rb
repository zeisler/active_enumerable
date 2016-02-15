require "spec_helper"

RSpec.describe ActiveEnumerable::Finder do
  describe "#is_of" do
    subject { described_class.new(record) }

    context "regex condition" do
      let(:record) { { name: "Timmy" } }

      it { expect(subject.is_of({ name: /Tim/ })).to eq(true) }
      it { expect(subject.is_of({ name: /Tix/ })).to eq(false) }
    end

    context "hash condition" do
      let(:record) { { name: "Timmy", parents: [{ name: "Dad", age: 33 }, { name: "Mom", age: 29 }] } }

      context "matches array of partial hashes identities" do
        it { expect(subject.is_of(parents: [{ name: "Dad" }, { name: "Mom" }])).to eq(true) }
        it { expect(subject.is_of(parents: [{ name: "Dad", age: 29 }, { name: "Mom", age: 33 }])).to eq(false) }
        it { expect(subject.is_of(parents: [{ name: "Dad", age: 33 }, { name: "Mom", age: 29 }])).to eq(true) }
      end

      context "matches partial hashes identities to an array of hashes" do
        it { expect(subject.is_of(parents: { name: "Dad", age: 33 })).to eq(true) }
        it { expect(subject.is_of(parents: { name: "Dad", age: 29 })).to eq(false) }
        it { expect(subject.is_of(parents: { name: "Dad" })).to eq(true) }
      end
    end

    context "array condition" do
      let(:record) { { name: "Timmy" } }

      it { expect(subject.is_of({ name: %w(Timmy Fred) })).to eq(true) }
      it { expect(subject.is_of({ name: %w(Sammy Fred) })).to eq(false) }
      it { expect(subject.is_of({ name: ["Sammy", /Tim/] })).to eq(true) }
      it { expect(subject.is_of({ name: ["Sammy", /Tix/] })).to eq(false) }

      context "when match is equal to value" do
        let(:record) { { name: %w(Timmy Fred Jim) } }

        it { expect(subject.is_of(name: %w(Timmy Fred Jim))).to eq(true) }
        it { expect(subject.is_of(name: %w(Timmy Ted Jim))).to eq(false) }
      end
    end

    context "value condition" do
      let(:record) { { name: "Timmy", age: 10 } }

      it { expect(subject.is_of(name: "Timmy")).to eq(true) }
      it { expect(subject.is_of(name: "Jim")).to eq(false) }
      it { expect(subject.is_of(age: 10)).to eq(true) }
      it { expect(subject.is_of(name: 11)).to eq(false) }
    end
  end
end
