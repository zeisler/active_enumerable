require "active_enumerable/version"
require "active_enumerable/base"
require "active_enumerable/record_not_found"
require "active_enumerable/comparable"
require "active_enumerable/enumerable"
require "active_enumerable/finder"
require "active_enumerable/method_caller"
require "active_enumerable/scope_method"
require "active_enumerable/scopes"
require "active_enumerable/where"
require "active_enumerable/find"
require "active_enumerable/queries"
require "active_enumerable/english_dsl"

module ActiveEnumerable
  include Base
  include Enumerable
  include Comparable
  include Queries
  include Scopes
  include EnglishDsl

  module ClassMethods
    include Scopes::ClassMethods
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
