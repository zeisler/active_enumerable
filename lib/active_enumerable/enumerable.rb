module ActiveEnumerable
  module Enumerable
    include ::Enumerable

    def each(*args, &block)
      @collection.send(:each, *args, &block)
    end
  end
end
