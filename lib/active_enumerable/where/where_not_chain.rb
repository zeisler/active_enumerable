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
      def not(conditions = {})
        @parent_class.call(@collection.reject do |record|
          Finder.new(record).is_of(conditions)
        end)
      end
    end
  end
end
