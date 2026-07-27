package;

import backend.Achievements;
import backend.Controls;
import backend.Logging;
import backend.Paths;
import backend.Save;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.group.FlxContainer;

@:structInit private class FeyworksConfig {
  #if FEY_SAVE
	public var companyName(default, null):String = 'Unnamed';
	public var projectName(default, null):String = 'Unnamed';
	#end
  public var discordInvite(default, null):String = '';
	public var extraLogInfo(default, null):Void->String = () -> '';
	public var initialState(default, null):Class<FlxState>;
}

class Feyworks {
	public static var config(default, null):FeyworksConfig;
	static var initFunc:Void->FlxState;

	public static var overlayGroup:FlxContainer = new FlxContainer();
	public static var overlayCam:FlxCamera;

	/**
				Initializes Feyworks and associated classes. call this **only after** `new FlxGame(...)`. It *will* throw and yell at you if you call it before initializing `FlxGame`.
				Feywork's options and defaults are as follows:
			```haxe
			?companyName:String = 'Unnamed';// the name of the game's author.
			?projectName:String = 'Unnamed';// the name of the project.
			?discordInvite:String = '';// the link to your discord server, if one exists.
			?extraLogInfo:Void->String = ()->'';// function called during crash logging to provide project-specific info about the game state.
			initialState:Class<FlxState>;// the state to initialize onto. Has no default and is obligatory.
		?modsDirectory:String = 'mods';//the path to your mods folder, if `FEY_NO_MODDING` is not enabled.
```
	**/
	@:allow(Main)
	static function init(config:FeyworksConfig) {
		Feyworks.config = config;
		initFunc = Type.createInstance.bind(config.initialState, []);

		overlayCam = new FlxCamera();
		overlayCam.bgColor = 0x00000000;

		overlayGroup.camera = overlayCam;

		FlxG.cameras.add(overlayCam, false);
		FlxG.cameras.cameraAdded.add((cam) -> {
			if (cam == overlayCam)
				return;
			if (overlayCam.flashSprite != null)
				FlxG.cameras.remove(overlayCam, false);
			else {
				overlayCam = new FlxCamera();
				overlayCam.bgColor = 0x00000000;
				overlayGroup.camera = overlayCam;
			}
			FlxG.cameras.add(overlayCam);
		});

		FlxG.plugins.addPlugin(overlayGroup);
		FlxG.plugins.drawOnTop = true;

		Logging.init();

		#if FEY_CONTROLS
		Controls.init();
		#end
		#if FEY_ACHIEVEMENTS
		Achievements.init();
		#end
		#if (FEY_SAVE && (FEY_SAVESLOTS || FEY_SAVEGLOBAL))
		Save.init();
		#end
		restart();
	}

	public static function restart() {
		FlxG.switchState(initFunc);
	}
}
