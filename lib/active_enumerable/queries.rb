module ActiveEnumerable
  module Queries
    include ActiveEnumerable::Where

    # Find by id - This can either be a specific id (1), a list of ids (1, 5, 6), or an array of ids ([5, 6, 10]).
    # If no record can be found for all of the listed ids, then RecordNotFound will be raised. If the primary key
    # is an integer, find by id coerces its arguments using +to_i+.
    #
    #   <#ActiveEnumerable>.find(1)          # returns the object for ID = 1
    #   <#ActiveEnumerable>.find(1, 2, 6)    # returns an array for objects with IDs in (1, 2, 6)
    #   <#ActiveEnumerable>.find([7, 17])    # returns an array for objects with IDs in (7, 17)
    #   <#ActiveEnumerable>.find([1])        # returns an array for the object with ID = 1
    #
    # <tt>ActiveEnumerable::RecordNotFound</tt> will be raised if one or more ids are not found.
    def find(ids)
      raise RecordNotFound.new("Couldn't find #{self.name} without an ID") if ids.nil?
      results = [*ids].map do |id|
        find_by!(id: id.to_i)
      end
      return __new_relation__(results) if ids.class == Array
      results.first
    end

    # Updates all records with details given if they match a set of conditions supplied, limits and order can
    # also be supplied.
    #
    # ==== Parameters
    #
    # * +updates+ - A string, array, or hash.
    #
    # ==== Examples
    #
    #   # Update all customers with the given attributes
    #   <#ActiveEnumerable>.update_all wants_email: true
    #
    #   # Update all books with 'Rails' in their title
    #   <#ActiveEnumerable>.where(title: 'Rails').update_all(author: 'David')
    #
    #   # Update all books that match conditions, but limit it to 5 ordered by date
    #   <#ActiveEnumerable>.where(title: 'Rails').order(:created_at).limit(5).update_all(author: 'David')
    def update_all(attributes)
      all.each { |i| i.update(attributes) }
    end

    # Updates an object (or multiple objects) and saves it.
    #
    # ==== Parameters
    #
    # * +id+ - This should be the id or an array of ids to be updated.
    # * +attributes+ - This should be a hash of attributes or an array of hashes.
    #
    # ==== Examples
    #
    #   # Updates one record
    #   <#ActiveEnumerable>.update(15, user_name: 'Samuel', group: 'expert')
    #
    #   # Updates multiple records
    #   people = { 1 => { "first_name" => "David" }, 2 => { "first_name" => "Jeremy" } }
    #   <#ActiveEnumerable>.update(people.keys, people.values)
    def update(id, attributes)
      if id.is_a?(Array)
        id.map.with_index { |one_id, idx| update(one_id, attributes[idx]) }
      else
        object = find(id)
        object.update(attributes)
        object
      end
    end

    # Finds the first record matching the specified conditions. There
    # is no implied ordering so if order matters, you should specify it
    # yourself.
    #
    # If no record is found, returns <tt>nil</tt>.
    #
    #   <#ActiveEnumerable>.find_by name: 'Spartacus', rating: 4
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

    # Finds the first record with the given attributes, or creates a record
    # with the attributes if one is not found:
    #
    #   # Find the first user named "Penélope" or create a new one.
    #   <#ActiveEnumerable>.find_or_create_by(first_name: 'Penélope')
    #   # => #<User id: 1, first_name: "Penélope", last_name: nil>
    #
    #   # Find the first user named "Penélope" or create a new one.
    #   # We already have one so the existing record will be returned.
    #   <#ActiveEnumerable>.find_or_create_by(first_name: 'Penélope')
    #   # => #<User id: 1, first_name: "Penélope", last_name: nil>
    #
    # This method accepts a block, which is passed down to +create+. The last example
    # above can be alternatively written this way:
    #
    #   # Find the first user named "Scarlett" or create a new one with a
    #   # different last name.
    #   <#ActiveEnumerable>.find_or_create_by(first_name: 'Scarlett') do |user|
    #     user.last_name = 'Johansson'
    #   end
    #   # => #<User id: 2, first_name: "Scarlett", last_name: "Johansson">
    #
    def find_or_create_by(attributes, &block)
      find_by(attributes) || create(attributes, &block)
    end

    alias_method :find_or_create_by!, :find_or_create_by

    # Like <tt>find_or_create_by</tt>, but calls <tt>new</tt> instead of <tt>create</tt>.
    def find_or_initialize_by(attributes, &block)
      find_by(attributes) || new(attributes, &block)
    end

    # Count the records.
    #
    #   <#ActiveEnumerable>.count
    #   # => the total count of all people
    #
    #   <#ActiveEnumerable>.count(:age)
    #   # => returns the total count of all people whose age is not nil
    def count(name = nil)
      return all.size if name.nil?
      where.not(name => nil).size
    end

    # Specifies a limit for the number of records to retrieve.
    #
    #   <#ActiveEnumerable>.limit(10)
    def limit(num)
      relation = __new_relation__(all.take(num))
      relation.send(:set_from_limit)
      relation
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
      BigDecimal.new(total) / BigDecimal.new(values.count)
    end

    # Calculates the minimum value on a given attribute. The value is returned
    # with the same data type of the attribute, or +nil+ if there's no row.
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
    def order(key)
      __new_relation__(all.sort_by { |item| MethodCaller.new(item).call(key) })
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
      all.map { |obj| obj.send(key) }
    end
  end
end
