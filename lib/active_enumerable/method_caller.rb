module ActiveEnumerable
  # @private
  class MethodCaller
    attr_reader :__object__, :raise_no_method

    def initialize(object, raise_no_method: true)
      @__object__      = object
      @raise_no_method = raise_no_method
    end

    def call(method)
      if __object__.is_a? Hash
        wrap_return __object__.fetch(method)
      else
        wrap_return __object__.public_send(method)
      end
    rescue NoMethodError => e
      raise e if raise_no_method
    rescue KeyError => e
      raise e, "#{e.message} for #{__object__}" if raise_no_method
    end

    def method_missing(method)
      call(method)
    end

    private

    def wrap_return(return_value)
      case return_value
      when Hash
        self.class.new(return_value, raise_no_method: raise_no_method)
      else
        return_value
      end
    end
  end
end
