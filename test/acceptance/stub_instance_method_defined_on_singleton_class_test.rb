require File.expand_path('../stub_method_shared_tests', __FILE__)

class StubInstanceMethodDefinedOnSingletonClassTest < Mocha::TestCase
  include StubMethodSharedTests

  def method_owner
    callee.singleton_class
  end

  def callee
    @callee ||= Class.new.new
  end
end
