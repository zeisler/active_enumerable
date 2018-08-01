require "active_enumerable/finder"
require "active_enumerable/where/where_not_chain"
require "active_enumerable/where/where_or_chain"

module ActiveEnumerable
  module Where
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
    #    <#ActiveEnumerable>.where(contracts:[{ created_at: (Time.now.midnight - 1.day)..Time.now.midnight }])
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
    #
    # @see ActiveEnumerable::Finder#is_of for all usages of conditions.
    def where(conditions = nil, &block)
      return WhereNotChain.new(all, method(:__new_relation__)) unless conditions || block
      conditions = conditions || { nil => block }
      create_where_relation(conditions, to_a.select do |record|
        Finder.new(record).is_of(conditions || { nil => block })
      end).tap do |where|
        where.extend(WhereOrChain)
        where.original_collection = to_a
      end
    end

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
