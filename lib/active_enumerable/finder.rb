module ActiveEnumerable

  class Finder
    def initialize(record)
      @method_caller = MethodCaller.new(record)
    end

    # Regex conditions
    #   Finder.new({ name: "Timmy" }).is_of({ name: /Tim/ })
    #     #=> true
    #
    # Hash conditions
    #   record = { name: "Timmy", parents: [{ name: "Dad", age: 33 }, { name: "Mom", age: 29 }] } }
    #
    #   Matching array of partial hashes identities
    #     Finder.new(record).is_of(parents: [{ name: "Dad" }, { name: "Mom" }]))
    #       #=> true
    #
    #   Matching partial hashes identities to an array of hashes
    #     Finder.new(record).is_of(parents: { name: "Dad", age: 33 })
    #       #=> true
    #
    # Array conditions
    #   record = { name: "Timmy" }
    #
    #   Finder.new(record).is_of(name: %w(Timmy Fred))
    #     #=> true
    #   Finder.new(record).is_of(name: ["Sammy", /Tim/])
    #     #=> true
    #
    # Value conditions
    #   record = { name: "Timmy", age: 10 }
    #
    #   Finder.new(record).is_of(name: "Timmy")
    #     #=> true
    #   Finder.new(record).is_of(age: 10)
    #     #=> true
    #
    # @param [Hash] conditions
    # @return [true, false]
    def is_of(conditions = {})
      conditions.all? do |col, match|
        case match
        when Proc
          proc_match(col, match)
        when Hash
          hash_match(col, match)
        when Array
          array_match(col, match)
        else
          compare(col, match)
        end
      end
    end

    private

    def proc_match(col, match)
      return @method_caller.instance_exec(&match) unless col
      next_record = @method_caller.call(col)
      if next_record.is_a? Array
        next_record.all? { |record| Finder.new(record).is_of({nil => match}) }
      else
        MethodCaller.new(next_record).instance_exec(&match)
      end
    end

    def hash_match(col, match)
      next_record = @method_caller.call(col)
      if next_record.is_a? Array
        next_record.any? { |record| Finder.new(record).is_of(match) }
      else
        Finder.new(next_record).is_of(match)
      end
    end

    def array_match(col, match)
      if @method_caller.call(col).is_a? Array
        if !(r = compare(col, match)) && match.map(&:class).uniq == [Hash]
          match.all? { |m| hash_match(col, m) }
        else
          r
        end
      else
        match.any? { |m| compare(col, m) }
      end
    end

    def compare(col, match)
      @method_caller.call(col).public_send(compare_by(match), match)
    end

    def compare_by(match)
      (match.is_a? Regexp) ? :=~ : :==
    end
  end
end
