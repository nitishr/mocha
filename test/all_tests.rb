require 'test/unit/ui/console/testrunner'

require 'mocha/inspect_test'
require 'mocha/pretty_parameters_test'
require 'mocha/expectation_test'
require 'mocha/infinite_range_test'
require 'mocha/mock_methods_test'
require 'mocha/mock_test'
require 'mocha/auto_verify_test'

require 'auto_mocha/mock_class_test'
require 'auto_mocha/auto_mock_test'

require 'stubba/central_test'
require 'stubba/class_method_test'
require 'stubba/instance_method_test'
require 'stubba/any_instance_method_test'
require 'stubba/setup_and_teardown_test'
require 'stubba/object_test'

require 'multiple_setup_and_teardown_test'

class UnitTests
  
  def self.suite
    suite = Test::Unit::TestSuite.new('UnitTests')
    suite << InspectTest.suite
    suite << PrettyParametersTest.suite
    suite << ExpectationTest.suite
    suite << InfiniteRangeTest.suite
    suite << MockMethodsTest.suite
    suite << MockTest.suite
    suite << AutoVerifyTest.suite
    suite << MockClassTest.suite
    suite << AutoMockTest.suite
    suite << CentralTest.suite
    suite << ClassMethodTest.suite
    suite << InstanceMethodTest.suite
    suite << AnyInstanceMethodTest.suite
    suite << SetupAndTeardownTest.suite
    suite << ObjectTest.suite
    suite << MultipleSetupAndTeardownTest.suite
    suite
  end
  
end

Test::Unit::UI::Console::TestRunner.run(UnitTests)

require 'stubba_integration_test'

class IntegrationTests
  
  def self.suite
    suite = Test::Unit::TestSuite.new('IntegrationTests')
    suite << StubbaIntegrationTest.suite
  end
  
end

Test::Unit::UI::Console::TestRunner.run(IntegrationTests)

require 'mocha_acceptance_test'
require 'auto_mock_acceptance_test'
require 'stubba_acceptance_test'

class AcceptanceTests
  
  def self.suite
    suite = Test::Unit::TestSuite.new('AcceptanceTests')
    suite << MochaAcceptanceTest.suite
    suite << AutoMockAcceptanceTest.suite
    suite << StubbaAcceptanceTest.suite
    suite
  end
  
end

Test::Unit::UI::Console::TestRunner.run(AcceptanceTests)
