module ActiveEnumerable
  module Base
    include ::Enumerable

    def each(*args, &block)
      @collection.send(:each, *args, &block)
    end

    def initialize(collection=[])
      active_enumerable_setup(collection)
    end

    def active_enumerable_setup(collection=[])
      if collection.is_a? ::Enumerator::Lazy
        @collection = collection
      else
        @collection = collection.to_a
      end
    end

    def to_a
      @collection.to_a
    end

    def <<(item)
      @collection << item
    end

    alias_method :add, :<<

    def all
      self.tap { to_a }
    end

    def name
      self.class.name
    end

    # @private
    def __new_relation__(collection)
      self.class.new(collection)
    end
  end
end
