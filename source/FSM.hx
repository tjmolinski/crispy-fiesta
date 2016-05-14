package;

/**
 * ...
 * @author TJ
 */
 class FSM<T>
 {
     public var activeState:FSMState;
	 public var owner:T;

     public function new(?_owner:T, ?InitState:FSMState):Void
     {
		 owner = _owner;
         activeState = new InitState();
     }

     public function update(elapsed:Float):Void
     {
         if (activeState != null)
		 {
             activeState(elapsed);
		 }
     }
	 
	 public function transition(newState:FSMState):Void
	 {
		activeState.exit();
		activeState = newState;
		activeState.enter();
	 }
 }