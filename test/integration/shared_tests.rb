# frozen_string_literal: true

require 'test_runner'
require 'execution_point'
require 'mocha/ruby_version'

# rubocop:disable Metrics/ModuleLength
module SharedTests
  include TestRunner

  def test_assertion_satisfied
    test_result = run_as_test do
      assert true
    end
    assert_passed(test_result)
  end

  def test_assertion_unsatisfied
    execution_point = nil
    test_result = run_as_test do
      execution_point = ExecutionPoint.current; flunk
    end
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
  end

  def test_mock_object_unexpected_invocation
    execution_point = nil
    test_result = run_as_test do
      mock = mock('not expecting invocation')
      execution_point = ExecutionPoint.current; mock.unexpected
    end
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
    assert_equal ['unexpected invocation: #<Mock:not expecting invocation>.unexpected()'], test_result.failure_message_lines
  end

  def test_mock_object_explicitly_unexpected_invocation
    execution_point = nil
    test_result = run_as_test do
      mock = mock('not expecting invocation')
      mock.expects(:unexpected).never
      execution_point = ExecutionPoint.current; mock.unexpected
    end
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
    assert_equal [
      'unexpected invocation: #<Mock:not expecting invocation>.unexpected()',
      'unsatisfied expectations:',
      '- expected never, invoked once: #<Mock:not expecting invocation>.unexpected(any_parameters)'
    ], test_result.failure_message_lines
  end

  def test_mock_object_unsatisfied_expectation
    execution_point = nil
    test_result = run_as_test do
      mock = mock('expecting invocation')
      execution_point = ExecutionPoint.current; mock.expects(:expected)
    end
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
    assert_equal [
      'not all expectations were satisfied',
      'unsatisfied expectations:',
      '- expected exactly once, invoked never: #<Mock:expecting invocation>.expected(any_parameters)'
    ], test_result.failure_message_lines
  end

  def test_mock_object_unexpected_invocation_in_setup
    execution_point = nil
    test_result = run_as_tests(
      setup: lambda {
        mock = mock('not expecting invocation')
        execution_point = ExecutionPoint.current; mock.unexpected
      },
      test_me: lambda {
        assert true
      }
    )
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
    assert_equal ['unexpected invocation: #<Mock:not expecting invocation>.unexpected()'], test_result.failure_message_lines
  end

  def test_mock_object_unsatisfied_expectation_in_setup
    execution_point = nil
    test_result = run_as_tests(
      setup: lambda {
        mock = mock('expecting invocation')
        execution_point = ExecutionPoint.current; mock.expects(:expected)
      },
      test_me: lambda {
        assert true
      }
    )
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
    assert_equal [
      'not all expectations were satisfied',
      'unsatisfied expectations:',
      '- expected exactly once, invoked never: #<Mock:expecting invocation>.expected(any_parameters)'
    ], test_result.failure_message_lines
  end

  def test_mock_object_unexpected_invocation_in_teardown
    execution_point = nil
    test_result = run_as_tests(
      test_me: lambda {
        assert true
      },
      teardown: lambda {
        mock = mock('not expecting invocation')
        execution_point = ExecutionPoint.current; mock.unexpected
      }
    )
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
    assert_equal ['unexpected invocation: #<Mock:not expecting invocation>.unexpected()'], test_result.failure_message_lines
  end

  def test_real_object_explicitly_unexpected_invocation
    execution_point = nil
    object = Object.new
    test_result = run_as_test do
      object.expects(:unexpected).never
      execution_point = ExecutionPoint.current; object.unexpected
    end
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
    assert_equal [
      "unexpected invocation: #{object.mocha_inspect}.unexpected()",
      'unsatisfied expectations:',
      "- expected never, invoked once: #{object.mocha_inspect}.unexpected(any_parameters)"
    ], test_result.failure_message_lines
  end

  def test_real_object_unsatisfied_expectation
    execution_point = nil
    object = Object.new
    test_result = run_as_test do
      execution_point = ExecutionPoint.current; object.expects(:expected)
    end
    assert_failed(test_result)
    failure = test_result.failures.first
    assert_equal execution_point, ExecutionPoint.new(failure.location)
    assert_equal [
      'not all expectations were satisfied',
      'unsatisfied expectations:',
      "- expected exactly once, invoked never: #{object.mocha_inspect}.expected(any_parameters)"
    ], test_result.failure_message_lines
  end

  def test_real_object_expectation_does_not_leak_into_subsequent_test
    opening_quote = Mocha::RUBY_V34_PLUS ? "'" : '`'

    execution_point = nil
    klass = Class.new
    test_result = run_as_tests(
      test_1: lambda {
        klass.expects(:foo)
        klass.foo
      },
      test_2: lambda {
        execution_point = ExecutionPoint.current; klass.foo
      }
    )
    assert_errored(test_result)
    exception = test_result.errors.first.exception
    assert_equal execution_point, ExecutionPoint.new(exception.backtrace)
    assert_match(/undefined method #{opening_quote}foo'/, exception.message)
  end

  def test_leaky_mock
    origin = nil
    leaky_mock = nil
    execution_point = nil
    test_result = run_as_tests(
      test_1: lambda {
        origin = mocha_test_name
        leaky_mock ||= begin
          bad_mock = mock(:leaky)
          bad_mock.expects(:call)
          bad_mock
        end

        leaky_mock.call
      },
      test_2: lambda {
        leaky_mock ||= begin
          bad_mock = mock(:leaky)
          bad_mock.expects(:call)
          bad_mock
        end

        execution_point = ExecutionPoint.current; leaky_mock.call
      }
    )
    assert_errored(test_result)
    exception = test_result.errors.first.exception
    assert_equal execution_point, ExecutionPoint.new(exception.backtrace)
    expected = /#<Mock:leaky> was instantiated in #{Regexp.escape(origin)} but it is receiving invocations within another test/
    assert_match(expected, exception.message)
  end
end
# rubocop:enable Metrics/ModuleLength
