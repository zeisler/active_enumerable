module ActiveEnumerable
  module Base
    def initialize(collection=[])
      if collection.is_a? ::Enumerator::Lazy
        @collection = collection
      else
        @collection = collection.to_a
      end
    end

    def to_a
      @collection.to_a
    end

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
      @collection << item
    end

    def all
      self.tap { to_a }
    end

    def name
      self.class.name
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
