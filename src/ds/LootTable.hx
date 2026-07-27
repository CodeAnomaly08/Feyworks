package ds;

import flixel.FlxG;
import backend.Logging;
import haxe.extern.EitherType;
import ds.Pool;

class ItemTable<T> {
	var items:Array<{
		chance:Float,
		min:Int,
		max:Int,
		pool:Pool<T>
	}> = [];

	public function new() {}

	public function add(chance:Float = 100, minAmount:Int = 1, maxAmount:Int = 1, vals:Array<T>, ?weights:Array<Float>) {
		weights = weights ?? [for (i in 0...vals.length) 1];

		if (vals.length != weights.length)
			return Logging.warn('Unable to add pool to loot table: Items and weights do not match');

		var pool = new Pool<T>();
		for (i => v in vals) {
			pool.add(v, weights[i]);
		}

		addPool(chance, minAmount, maxAmount, pool);
	}

	// so I can reuse premade tables for common stuff, perhaps
	public inline function addPool(chance:Float = 100, minAmount:Int = 1, maxAmount:Int = 1, pool:Pool<T>) {
		items.push({
			pool: pool,
			chance: chance,
			min: minAmount,
			max: maxAmount
		});
	}

	public function get():Array<{item:T, count:Int}> {
		var returnItems:Array<{item:T, count:Int}> = [];

		for (index => pool in items) {
			if (FlxG.random.float(0, 100) >= pool.chance)
				continue;

			var amount = FlxG.random.int(pool.min, pool.max)
			returnItems.push({item: pool.pool.get(), count: amount});
		}
		return returnItems;
	}
}
