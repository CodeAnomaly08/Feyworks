package backend;
#if (FEY_SAVE)

import flixel.FlxG;
// project-side file with data structures and functions, so each project can define its own schema
#if FEY_SAVESLOTS
import Schema.SlotSchema;
import Schema.createSlot;
import Schema.cloneSlot;
#end
#if FEY_SAVEGLOBAL
import Schema.GlobalSchema;
import Schema.createGlobal;
import Schema.cloneGlobal;
#end

/**Class for saving user data, both in slots and in global data.
	Can be disabled via `FEY_NO_SAVE`, also supports flags `FEY_NO_SAVESLOTS` and `FEY_NO_SAVEGLOBAL`, for disabling only a part of it.
	  (if `FEY_NO_SLOTS` is enabled, and global data has not been disabled, it uses `Save.data` rather than `save.global`, as the distinction is no longer necessary)
**/
class Save {
	#if FEY_SAVEGLOBAL
	#if FEY_SLOTS
	static var global:GlobalSchema;
	#else
	static var data:GlobalSchema;
	#end
	#end
	#if FEY_SLOTS
	static var current:SlotSchema;
	static var slots:Map<Int, SlotSchema>;
	#end

	@:allow(Feyworks)
	static function init() {
		FlxG.save.bind(Feyworks.config.projectName, Feyworks.config.companyName);

		#if FEY_SAVESLOTS
		// I'm tired of repeating it, haxe.Serializer explicitly supports all types of maps.
		if (FlxG.save.data.slots == null)
			FlxG.save.data.slots = new Map<Int, SlotSchema>();

		current = createSlot();
		slots = [
			for (i => slot in (cast FlxG.save.data.slots : Map<Int, SlotSchema>)) i => cloneSlot(slot)
		];
		#end

		#if FEY_SAVEGLOBAL
		if (FlxG.save.data.global == null)
			FlxG.save.data.global = createGlobal();
		global = cloneGlobal(FlxG.save.data.global);
		#end

		commit(); // saves default structure if not there, achieves nothing otherwise
	}

	#if FEY_SAVESLOTS
	public static function loadSlot(index:Int) {
		var slot = slots.get(index);
		if (slot == null)
			return Logging.warn('Unable to load slot $index: null slot!');
		current = cloneSlot(slot);
	}

	public static function wipeSlot(index:Int) {
		slots.remove(index);
		FlxG.save.data.slots.remove(index);
		commit();
	}

	public static function saveSlot(index:Int, ?data:SlotSchema) {
		slots.set(index, cloneSlot(data ?? current));
		FlxG.save.data.slots.set(index, cloneSlot(data ?? current));
		commit();
	}
	#end

	#if FEY_SAVEGLOBAL
	public static function saveGlobal() {
		FlxG.save.data.global = cloneGlobal(global);
		commit();
	}
	#end

	public static function commit() {
		FlxG.save.flush();
	}
}
#end
