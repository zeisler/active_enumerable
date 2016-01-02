module ActiveEnumerable
  module Enumerable
    include ::Enumerable

    def initialize(collection)
      @to_a = collection.to_ary
    end

    attr_reader :to_a

    def each(*args, &block)
      to_a.send(:each, *args, &block)
    end
  end
end
