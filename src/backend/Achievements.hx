package backend;
#if FEY_ACHIEVEMENTS
/**
	I was gonna integrate this into Save, but since `FEY_NO_SAVE` is a thing, it'd be too much hassle to integrate them taking all the flags into account
**/

import flixel.FlxG;

private typedef Achievement = {
	var name:String; var ?description:String; var ?image:String;
}

class Achievements {
	// I'll figure out something for initializing achievements later
	static var achievements:Map<String, Achievement> = new Map();

	@:allow(Feyworks)
	static function init() {
		FlxG.save.bind(Feyworks.config.projectName, Feyworks.config.companyName);
		if (FlxG.save.data.achievements == null)
			FlxG.save.data.achievements = new Map<String, Bool>();
		FlxG.save.flush(); // save achievement map, if it had to be created
	}

	public static function listAchieved() {
		return [for (k => v in achievements) if (has(k)) v];
	}

	public static function list() {
		return [for (i in achievements) i.name];
	}

	public static function has(achievement:String) {
		if (!FlxG.save.isBound)
			return {Logging.warn('Unable to fetch achievement status: FlxG is not bound yet!'); false;};
		return (cast FlxG.save.data.achievements : Map<String, Bool>).get(achievement) ?? false;
	}

	public static inline function exists(achievement:String) {
		return achievements.exists(achievement);
	}

	public static function grant(achievement:String) {
		if (!FlxG.save.isBound)
			return Logging.warn('Unable to grant achievement: FlxG is not bound yet!');
		if (!exists(achievement))
			return Logging.warn('Failed to grant achievement $achievement: does not exist!');
		(cast FlxG.save.data.achievements : Map<String, Bool>).set(achievement, true);
		FlxG.save.flush();
	}

	public static function revoke(achievement:String) {
		if (!FlxG.save.isBound)
			return Logging.warn('Unable to revoke achievement: FlxG is not bound yet!');
		if (!exists(achievement))
			return Logging.warn('Failed to revoke achievement $achievement: does not exist!');
		(cast FlxG.save.data.achievements : Map<String, Bool>).set(achievement, false);
		FlxG.save.flush();
	}
}
#end
