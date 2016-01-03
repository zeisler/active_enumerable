module ActiveEnumerable
  module Enumerable
    include ::Enumerable

    def each(*args, &block)
      to_a.send(:each, *args, &block)
    end

    attr_reader :to_a
  end
end
