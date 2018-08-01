module ActiveEnumerable
  module EnglishDsl
    include ScopeMethod
    include Where

    UnmetCondition = Class.new(StandardError)

    # @param [Hash]
    # @yield takes block to evaluate English Dsl
    #   <ActiveEnumerable>#where{ has(:name).of("Dustin") }
    # @return [ActiveEnumerable]
    def where(*args, &block)
      if block_given?
        scope(&block).send(:_english_eval__)
      else
        super
      end
    end

    # @param [String, Symbol] attr is either a method name a Hash key.
    #   has(:name)
    def has(attr)
      all_conditions << [attr]
      self
    end

    # @param [Hash, Object] matches is list of sub conditions or associations to query.
    #   Or this can by any value to compare the result from attr.
    def of(matches=nil, &block)
      raise ArgumentError if matches.nil? && block.nil?
      if all_conditions.empty? || !(all_conditions.last.count == 1)
        raise UnmetCondition, ".has(attr) must be call before calling #of."
      else
        all_conditions.last << (matches || block)
        self
      end
    end

    # After calling #of(matches) providing additional matches to #or(matches) build a either or query.
    # @param [Hash, Object] matches is list of sub conditions or associations to query.
    #   Or this can by any value to compare the result from attr.
    def or(matches)
      raise UnmetCondition, ".has(attr).of(matches) must be call before calling #or(matches)." if all_conditions.empty? || !(all_conditions.last.count == 2)
      evaluation_results << english_where
      all_conditions.last[1] = matches
      evaluation_results << english_where
      self
    end

    # @param [Hash, Object, NilClass] matches is list of sub conditions or associations to query.
    #   Or this can by any value to compare the result from attr.
    #   Or passing nothing and provide a different has(attr)
    #     has(attr).of(matches).and.has(other_attr)
    def and(matches=nil)
      if matches
        all_conditions.last[1].merge!(matches)
        evaluation_results << english_where
      end
      self
    end

    private

    def all_conditions
      @all_conditions ||= []
    end

    def _english_eval__
      if evaluation_results.empty?
        english_where
      else
        __new_relation__ evaluation_results.flat_map(&:to_a).uniq
      end
    end

    def english_where
      where all_conditions.each_with_object({}) { |e, h| h[e[0]] = e[1] }
    end

    def evaluation_results
      @evaluation_results ||= []
    end
  end
end
