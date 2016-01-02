module ActiveEnumerable
  module Where
    class Find
      def initialize(record)
        @record = record
      end

      def is_of(conditions={})
        conditions.all? do |col, match|
          if match.is_a? Hash
            hash_match(col, match)
          elsif match.is_a? Enumerable
            any_match(col, match)
          else
            compare(col, match)
          end
        end
      end

      private

      def hash_match(col, match)
        self.class.new(@record.send(col)).is_of(match)
      end

      def any_match(col, match)
        match.any? { |m| compare(col, m) }
      end

      def compare(col, match)
        if @record.is_a? Hash
          @record.fetch(col) == match
        else
          @record.send(col) == match
        end
      end
    end

    class WhereNotChain

      def initialize(collection, parent_class)
        @collection   = collection
        @parent_class = parent_class
      end

      def not(conditions={})
        @parent_class.call(@collection.reject do |record|
          Find.new(record).is_of(conditions)
        end)
      end
    end

    # Returns a new relation, which is the result of filtering the current relation
    # according to the conditions in the arguments.
    #
    # === hash
    #
    # #where will accept a hash condition, in which the keys are fields and the values
    # are values to be searched for.
    #
    # Fields can be symbols or strings. Values can be single values, arrays, or ranges.
    #
    #    User.where({ name: "Joe", email: "joe@example.com" })
    #
    #    User.where({ name: ["Alice", "Bob"]})
    #
    #    User.where({ created_at: (Time.now.midnight - 1.day)..Time.now.midnight })
    #
    # In the case of a belongs_to relationship, an association key can be used
    # to specify the model if an ActiveRecord object is used as the value.
    #
    #    author = Author.find(1)
    #
    #    # The following queries will be equivalent:
    #    Post.where(author: author)
    #    Post.where(author_id: author)
    #
    # This also works with polymorphic belongs_to relationships:
    #
    #    treasure = Treasure.create(name: 'gold coins')
    #    treasure.price_estimates << PriceEstimate.create(price: 125)
    #
    #    # The following queries will be equivalent:
    #    PriceEstimate.where(estimate_of: treasure)
    #    PriceEstimate.where(estimate_of_type: 'Treasure', estimate_of_id: treasure)
    #
    # === no argument
    #
    # If no argument is passed, #where returns a new instance of WhereChain, that
    # can be chained with #not to return a new relation that negates the where clause.
    #
    #    User.where.not(name: "Jon")
    #
    # See WhereChain for more details on #not.
    def where(conditions=nil)
      return WhereNotChain.new(all, method(:__new_relation__)) if conditions.nil?
      enable_or __new_relation__(to_a.select do |record|
        Find.new(record).is_of(conditions)
      end)
    end

    def enable_or(relation)
      pre_where_to_a = to_a
      relation.define_singleton_method(:or) do |conditions|
        or_result = __new_relation__(pre_where_to_a).where(conditions).to_a
        __new_relation__ [*relation.to_a, *or_result.to_a]
      end
      relation
    end

    private :enable_or
  end
end
