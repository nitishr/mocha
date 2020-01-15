require File.expand_path('../stubbing_with_potential_violation_is_checked', __FILE__)

if RUBY_VERSION < '2.2.0'
  class StubbingNilTest < Mocha::TestCase
    include StubbingWithPotentialViolationIsChecked

    def configure_violation(config, treatment)
      config.stubbing_method_on_nil = treatment
    end

    def potential_violation
      nil.stubs(:stubbed_method)
    end

    def message_on_violation
      'stubbing method on nil: nil.stubbed_method'
    end

    def test_should_default_to_prevent_stubbing_method_on_nil
      test_result = stub_with_potential_violation
      assert_failed(test_result)
      assert test_result.error_messages.include?("Mocha::StubbingError: #{message_on_violation}")
    end

    def test_should_allow_stubbing_method_on_non_nil_object
      test_result = run_test_with_check(:prevent) do
        Object.new.stubs(:stubbed_method)
      end
      assert_passed(test_result)
    end
  end
end
