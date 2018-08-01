module ActiveEnumerable
  module Where
    module WhereOrChain
      def or(conditions_or_relation)
        conditions = get_conditions(conditions_or_relation)
        or_result  = create_where_relation(where_conditions, original_collection).where(conditions)
        create_where_relation(or_result.where_conditions, to_a.concat(or_result.to_a).uniq)
      end

      attr_accessor :original_collection

      private

      def get_conditions(conditions_or_relation)
        if conditions_or_relation.respond_to?(:where_conditions)
          conditions_or_relation.where_conditions
        else
          conditions_or_relation
        end
      end
    end
  end
end
