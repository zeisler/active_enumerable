module ActiveEnumerable
  module Base
    def initialize(collection=[])
      @to_a = collection.to_ary
    end

    attr_reader :to_a

    # @private
    def __new_relation__(collection)
      self.class.new(collection)
    end

    def create(attributes)
      add(if (klass = self.class.item_class)
            klass.new(attributes)
          else
            attributes
          end)
    end

    def add(item)
      to_a << item
    end

    def all
      self
    end

    module ClassMethods
      def item_class
        @item_class
      end

      def item_class=(klass)
        @item_class = klass
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
