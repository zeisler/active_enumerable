module ActiveEnumerable
  # @private
  class Finder
    def initialize(record)
      @method_caller = MethodCaller.new(record)
    end

    def is_of(conditions={})
      conditions.all? do |col, match|
        if match.is_a? Hash
          hash_match(col, match)
        elsif match.is_a? ::Enumerable
          any_match(col, match)
        else
          compare(col, match)
        end
      end
    end

    private

    def hash_match(col, match)
      next_record = @method_caller.call(col)
      if next_record.is_a? Array
        next_record.any? { |record| Finder.new(record).is_of(match) }
      else
        Finder.new(next_record).is_of(match)
      end
    end

    def any_match(col, match)
      match.any? { |m| compare(col, m) }
    end

    def compare(col, match)
      @method_caller.call(col) == match
    end
  end
end
