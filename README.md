# ActiveEnumerable

Include ActiveRecord like query methods to Ruby enumerable collections.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_enumerable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_enumerable

## Usage

```ruby
require "active_enumerable"

class Customers
  include ActiveEnumerable
  
  scope :unpaid, -> { where(paid: false).or(credit: 0) }
end

customers = Customers.new([{paid: true, credit: 1000}, {paid: false, credit: 2000}, {paid: false, credit: 0}])

customers.unpaid
  # => <#Customers [{:paid=>false, :credit=>2000}, {:paid=>false, :credit=>0}]]>
  
customers.scope { select { |y| y > 1000 } }
  #=> <#Customers [{paid: true, credit: 1000}, {paid: false, credit: 2000}]>
  
customers.sum(:credit)
  #=> 3000
  
customers.create({paid: true, credit: 1500}) # defaults to Hash creations

Customers.item_class = Customer

customers.create({paid: true, credit: 1500}).to_a.last
  #=> <#Customer paid: true, credit: 1500>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zeisler/active_enumerable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

