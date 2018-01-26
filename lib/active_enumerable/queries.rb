require "active_enumerable/order"
require "bigdecimal"

module ActiveEnumerable
  module Queries
    # Find by id - Depends on either having an Object#id or Hash{id: Integer}
    # This can either be a specific id (1), a list of ids (1, 5, 6), or an array of ids ([5, 6, 10]).
    # If no record can be found for all of the listed ids, then RecordNotFound will be raised. If the primary key
    # is an integer, find by id coerces its arguments using +to_i+.
    #
    #   <#ActiveEnumerable>.find(1)          # returns the object for ID = 1
    #   <#ActiveEnumerable>.find(1, 2, 6)    # returns an array for objects with IDs in (1, 2, 6)
    #   <#ActiveEnumerable>.find([7, 17])    # returns an array for objects with IDs in (7, 17)
    #   <#ActiveEnumerable>.find([1])        # returns an array for the object with ID = 1
    #
    # <tt>ActiveEnumerable::RecordNotFound</tt> will be raised if one or more ids are not found.
    # @return [ActiveEnumerable, Object]
    # @param [*Fixnum, Array<Fixnum>] args
    def find(*args)
      raise RecordNotFound.new("Couldn't find #{self.respond_to?(:name) ? self.name : self.class.name} without an ID") if args.compact.empty?
      if args.count > 1 || args.first.is_a?(Array)
        __new_relation__(args.flatten.lazy.map do |id|
          find_by!(id: id.to_i)
        end)
      else
        find_by!(id: args.first.to_i)
      end
    end

    # Finds the first record matching the specified conditions. There
    # is no implied ordering so if order matters, you should specify it
    # yourself.
    #
    # If no record is found, returns <tt>nil</tt>.
    #
    #   <#ActiveEnumerable>.find_by name: 'Spartacus', rating: 4
    #
    # # @see ActiveEnumerable::Finder#is_of for all usages of conditions.
    def find_by(conditions = {})
      to_a.detect do |record|
        Finder.new(record).is_of(conditions)
      end
    end

    # Like <tt>find_by</tt>, except that if no record is found, raises
    # an <tt>ActiveEnumerable::RecordNotFound</tt> error.
    def find_by!(conditions={})
      result = find_by(conditions)
      if result.nil?
        raise RecordNotFound.new("Couldn't find #{self.name} with '#{conditions.keys.first}'=#{conditions.values.first}")
      end
      result
    end

    # Count the records.
    #
    #   <#ActiveEnumerable>.count
    #   # => the total count of all people
    #
    #   <#ActiveEnumerable>.count(:age)
    #   # => returns the total count of all people whose age is not nil
    def count(name = nil)
      return to_a.size if name.nil?
      to_a.reject { |record| Finder.new(record).is_of(name: nil) }.size
    end

    # Specifies a limit for the number of records to retrieve.
    #
    #   <#ActiveEnumerable>.limit(10)
    def limit(num)
      __new_relation__(all.take(num))
    end

    # Calculates the sum of values on a given attribute. The value is returned
    # with the same data type of the attribute, 0 if there's no row.
    #
    #   <#ActiveEnumerable>.sum(:age) # => 4562
    def sum(key)
      values = values_by_key(key)
      values.inject(0) do |sum, n|
        sum + (n || 0)
      end
    end

    # Calculates the average value on a given attribute. Returns +nil+ if there's
    # no row.
    #
    #   <#ActiveEnumerable>.average(:age) # => 35.8
    def average(key)
      values = values_by_key(key)
      total  = values.inject { |sum, n| sum + n }
      return unless total
      BigDecimal.new(total) / BigDecimal.new(values.count)
    end

    # Calculates the minimum value on a given attribute. Returns +nil+ if there's
    # no row.
    #
    #   <#ActiveEnumerable>.minimum(:age) # => 7
    def minimum(key)
      values_by_key(key).min_by { |i| i }
    end

    # Calculates the maximum value on a given attribute. The value is returned
    # with the same data type of the attribute, or +nil+ if there's no row.
    #
    #   <#ActiveEnumerable>.maximum(:age) # => 93
    def maximum(key)
      values_by_key(key).max_by { |i| i }
    end

    # Allows to specify an order attribute:
    #
    #   <#ActiveEnumerable>.order('name')
    #
    #   <#ActiveEnumerable>.order(:name)
    #
    #   <#ActiveEnumerable>.order(email: :desc)
    #
    #   <#ActiveEnumerable>.order(:name, email: :desc)
    def order(*args)
      __new_relation__(Order.call(args, all))
    end


    # Reverse the existing order clause on the relation.
    #
    #   <#ActiveEnumerable>.order('name').reverse_order
    def reverse_order
      __new_relation__(to_a.reverse)
    end

    # Returns a chainable relation with zero records.
    #
    # Any subsequent condition chained to the returned relation will continue
    # generating an empty relation.
    #
    # Used in cases where a method or scope could return zero records but the
    # result needs to be chainable.
    #
    # For example:
    #
    #   @posts = current_user.visible_posts.where(name: params[:name])
    #   # => the visible_posts method is expected to return a chainable Relation
    #
    #   def visible_posts
    #     case role
    #     when 'Country Manager'
    #       <#ActiveEnumerable>.where(country: country)
    #     when 'Reviewer'
    #       <#ActiveEnumerable>.published
    #     when 'Bad User'
    #       <#ActiveEnumerable>.none # It can't be chained if [] is returned.
    #     end
    #   end
    #
    def none
      __new_relation__([])
    end

    private

    def values_by_key(key)
      all.map { |obj| MethodCaller.new(obj).call(key)  }
    end
  end
end
