module Mocha
  # A state machine that is used to constrain the order of invocations.
  # An invocation can be constrained to occur when a state {#is}, or {#is_not}, active.
  class StateMachine
    # Provides the ability to determine whether a {StateMachine} is in a specified state at some point in the future.
    class StatePredicate
      # @private
      def initialize(state_machine, state, description, &active_check)
        @state_machine = state_machine
        @state = state
        @description = description
        @active_check = active_check
      end

      # @private
      def active?
        @active_check.call(@state_machine.current_state, @state)
      end

      # @private
      def mocha_inspect
        "#{@state_machine.name} #{@description} #{@state.mocha_inspect}"
      end
    end

    # Provides a mechanism to change the state of a {StateMachine} at some point in the future.
    class State < StatePredicate
      # @private
      def activate
        @state_machine.current_state = @state
      end
    end

    # @private
    attr_reader :name

    # @private
    attr_accessor :current_state

    # @private
    def initialize(name)
      @name = name
      @current_state = nil
    end

    # Put the {StateMachine} into the state specified by +initial_state_name+.
    #
    # @param [String] initial_state_name name of initial state
    # @return [StateMachine] state machine, thereby allowing invocations of other {StateMachine} methods to be chained.
    def starts_as(initial_state_name)
      become(initial_state_name)
      self
    end

    # Put the {StateMachine} into the +next_state_name+.
    #
    # @param [String] next_state_name name of new state
    def become(next_state_name)
      @current_state = next_state_name
    end

    # Provides a mechanism to change the {StateMachine} into the state specified by +state_name+ at some point in the future.
    #
    # Or provides a mechanism to determine whether the {StateMachine} is in the state specified by +state_name+ at some point in the future.
    #
    # @param [String] state_name name of new state
    # @return [State] state which, when activated, will change the {StateMachine} into the state with the specified +state_name+.
    def is(state_name)
      State.new(self, state_name, 'is') { |current, given| current == given }
    end

    # Provides a mechanism to determine whether the {StateMachine} is not in the state specified by +state_name+ at some point in the future.
    def is_not(state_name) # rubocop:disable Naming/PredicateName
      StatePredicate.new(self, state_name, 'is not') { |current, given| current != given }
    end

    # @private
    def mocha_inspect
      %(#{@name} #{@current_state ? "is #{@current_state.mocha_inspect}" : 'has no current state'})
    end
  end
end
