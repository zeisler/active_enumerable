module ActiveEnumerable
  module Where
    class WhereNotChain
      def initialize(collection, parent_class)
        @collection   = collection
        @parent_class = parent_class
      end

      # Returns a new relation expressing WHERE + NOT condition according to
      # the conditions in the arguments.
      #
      # #not accepts conditions as a string, array, or hash. See Where#where for
      # more details on each format.
      #
      #    <#ActiveEnumerable>.where.not(name: "Jon")
      #    <#ActiveEnumerable>.where.not(name: nil)
      #    <#ActiveEnumerable>.where.not(name: %w(Ko1 Nobu))
      #    <#ActiveEnumerable>.where.not(name: "Jon", role: "admin")
      def not(conditions={})
        @parent_class.call(@collection.reject do |record|
          Finder.new(record).is_of(conditions)
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
    #    <#ActiveEnumerable>.where({ name: "Joe", email: "joe@example.com" })
    #
    #    <#ActiveEnumerable>.where({ name: ["Alice", "Bob"]})
    #
    #    <#ActiveEnumerable>.where({ created_at: (Time.now.midnight - 1.day)..Time.now.midnight })
    #
    # In the case of a belongs_to relationship, an association key can be used
    # to specify the model if an ActiveRecord object is used as the value.
    #
    #    author = <#ActiveEnumerable>.find(1)
    #
    #    # The following queries will be equivalent:
    #    <#ActiveEnumerable>.where(author: author)
    #    <#ActiveEnumerable>.where(author_id: author)
    #
    # This also works with polymorphic belongs_to relationships:
    #
    #    treasure = <#ActiveEnumerable>.create(name: 'gold coins')
    #    treasure.price_estimates << PriceEstimate.create(price: 125)
    #
    #    # The following queries will be equivalent:
    #    <#ActiveEnumerable>.where(estimate_of: treasure)
    #    <#ActiveEnumerable>.where(estimate_of_type: 'Treasure', estimate_of_id: treasure)
    #
    # .or
    #
    # Returns a new relation, which is the logical union of this relation and the one passed as an
    # argument.
    #
    # The two relations must be structurally compatible: they must be scoping the same model, and
    # they must differ only by #where.
    #
    #    <#ActiveEnumerable>.where(id: 1).or(<#ActiveEnumerable>.where(author_id: 3))
    #
    # Additional conditions can be passed to where in hash form.
    #
    #   <#ActiveEnumerable>.where(id: 1).or(author_id: 3)
    def where(conditions=nil)
      return WhereNotChain.new(all, method(:__new_relation__)) if conditions.nil?
      enable_or create_where_relation(conditions, to_a.select do |record|
        Finder.new(record).is_of(conditions)
      end)
    end

    def enable_or(relation)
      pre_where_to_a = to_a
      relation.define_singleton_method(:or) do |conditions_or_relation|
        conditions = get_conditions(conditions_or_relation)
        or_result = create_where_relation(where_conditions, pre_where_to_a).where(conditions)
        create_where_relation(or_result.where_conditions, relation.to_a.concat(or_result.to_a))
      end
      relation
    end

    private :enable_or

    def get_conditions(conditions_or_relation)
      if conditions_or_relation.respond_to?(:where_conditions)
        conditions_or_relation.where_conditions
      else
        conditions_or_relation
      end
    end

    private :get_conditions

    def where_conditions
      @where_conditions ||= {}
    end

    def create_where_relation(conditions, array)
      nr = __new_relation__(array)
      nr.where_conditions.merge!(conditions)
      nr
    end

    private :create_where_relation
  end
end
