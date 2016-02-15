module ActiveEnumerable
  module ScopeMethod
    def scope(&block)
      result = instance_exec(&block)
      if result.is_a? Array
        __new_relation__(result)
      else
        result
      end
    end
  end
end
