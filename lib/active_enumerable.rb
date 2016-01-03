require "active_enumerable/version"
require "active_enumerable/base"
require "active_enumerable/comparable"
require "active_enumerable/enumerable"
require "active_enumerable/finder"
require "active_enumerable/method_caller"
require "active_enumerable/scopes"
require "active_enumerable/where"
require "active_enumerable/queries"

module ActiveEnumerable
  include Base
  include Enumerable
  include Comparable
  include Queries
  include Scopes

  module ClassMethods
    include Scopes::ClassMethods
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
