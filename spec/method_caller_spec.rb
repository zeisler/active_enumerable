require "spec_helper"
require "ostruct"

RSpec.describe ActiveEnumerable::MethodCaller do

  describe "#call" do
    context "when object is hash" do
      it "returns the values" do
        expect(described_class.new({name: "David"}).call(:name)).to eq "David"
      end

      it "raises an error when no method" do
        expect{described_class.new({name: "David"}).call(:first_name)}.to raise_error(KeyError, %[key not found: :first_name for {:name=>"David"}])
      end

      it "returns nil when no method" do
        expect(described_class.new({name: "David"}, raise_no_method: false).call(:first_name)).to eq nil
      end
    end

    context "when is an object" do
      Person = Struct.new(:name)

      it "returns the values" do
        expect(described_class.new(Person.new("David")).call(:name)).to eq "David"
      end

      it "raises an error when no method" do
        expect{described_class.new(Person.new("David")).call(:first_name)}.to raise_error(NoMethodError, %[undefined method `first_name' for #<struct Person name="David">])
      end

      it "returns nil when no method" do
        expect(described_class.new(Person.new("David"), raise_no_method: false).call(:first_name)).to eq nil
      end
    end
  end
end
