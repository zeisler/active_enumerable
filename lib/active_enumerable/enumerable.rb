module ActiveEnumerable
  module Enumerable
    include ::Enumerable

    def each(*args, &block)
      @to_a.send(:each, *args, &block)
    end
  end
end
