require "spec_helper"

RSpec.describe ActiveEnumerable::Queries do

  class QueriesTestEnumerable
    include ActiveEnumerable::Base
    include ActiveEnumerable::Queries
  end

  subject { QueriesTestEnumerable.new(records) }
  let(:records) { [{ id: 2, name: "Fred" }, { id: 4, name: "Sam" }, { id: 5, name: "Dave" }] }

  describe "#find_by" do
    it "queries collection for object with name fred" do
      expect(subject.find_by(name: "Fred")).to eq({ id: 2, name: "Fred" })
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
end
