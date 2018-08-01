require 'spec_helper'

describe ActiveEnumerable do
  it 'has a version number' do
    expect(ActiveEnumerable::VERSION).to match(/d*\.\d*\.\d*/)
  end

  it "README example"do
    class Customers
      include ActiveEnumerable

      scope :unpaid, -> { where(paid: false).or(credit: 0) }
    end

    customers = Customers.new([{ paid: true, credit: 1000 }, { paid: false, credit: 2000 }, { paid: false, credit: 0 }])

    expect(customers.unpaid.to_a).to eq([{ :paid => false, :credit => 2000 }, { :paid => false, :credit => 0 }])

    expect(customers.scope { select { |y| y[:credit] >= 1000 } }.to_a).to eq([{ paid: true, credit: 1000 }, { paid: false, credit: 2000 }])

    expect(customers.sum(:credit)).to eq(3000)

    customers << { paid: true, credit: 1500 } # accepts Hashes

    class Customer
      attr_reader :paid, :credit

      def initialize(paid:, credit:)
        @paid   = paid
        @credit = credit
      end
    end

    customers << Customer.new(paid: true, credit: 1500) # Or Objects

    expect(customers.count).to eq(5)
  end

  it "README example" do
    class People
      include ActiveEnumerable

      scope :unpaid, -> { where(paid: false).or(credit: 0) }
    end

    people = People.new([{ name: "Reuben" }, { name: "Naomi" }])
    expect(people.where { has(:name).of("Reuben") }.to_a).to eq([{ name: "Reuben" }])


    people = People.new([
                          { name: "Reuben", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 33 }] },
                          { name: "Naomi", parents: [{ name: "Mom", age: 29 }, { name: "Dad", age: 41 }] }
                        ])


    expect(people.where { has(:parents).of(age: 29, name: "Mom").or(age: 33, name: "Dad") }).to eq(people)
  end
end
