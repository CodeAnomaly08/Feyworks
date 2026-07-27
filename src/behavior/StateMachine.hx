package behavior;

import backend.Logging;
import flixel.FlxBasic;

private typedef State = {
	var update:Float->Void;
	var ?enter:Void->Void;
	var ?exit:Void->Void;
}

abstract class ParentedStatemachine<T:FlxBasic> extends StateMachine{
  var parent:T;
  public function new(parent:T){
    this.parent = parent;
    super();
  }
}

abstract class StateMachine {
	public var curStateName(default, null):String = '';

	var curState:State = {update: e -> null, enter: () -> null, exit: () -> null};
	var stateMap(default,never):Map<String, State> = new Map();

	var timers(default,never):Map<String, {time:Float, action:Void->Void}> = new Map();

	var permatask:Float->Void = e -> null;

	public function new() {
		registerState('', e -> null);
		setup();
	}

	abstract function setup():Void;

	function registerState(name:String, fun:Float->Void, ?onEnter:Void->Void, ?onExit:Void->Void) {
		stateMap.set(name, {update: fun, enter: onEnter ?? () -> null, exit: onExit ?? () -> null});
	}

	function requestState(name:String) {
		if (name == curStateName)
			return;
		if (!stateMap.exists(name))
			return Logging.warn('Unable to load state $name: Null state!');
		curState.exit();
		curState = stateMap.get(name);
		curStateName = name;
		curState.enter();
	}

	inline function requestTimer(name:String, ?time:Float = 1, fun:Void->Void) {
		timers.set(name, {time: time, action: fun});
	}

	inline function cancelTimer(name:String) {
		timers.remove(name);
	}

  @:allow(entities.Entity)
	function update(e:Float) {
		var doneTimers = [];
		for (tag => timer in timers) {
			timer.time -= e;
			if (timer.time <= 0) {
				doneTimers.push(tag);
				timer.action();
			}
		}
		for (tag in doneTimers)
			cancelTimer(tag);
		curState.update(e);
		permatask(e);
	}
}
