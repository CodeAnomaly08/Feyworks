#if FEY_MODDING
package backend;

#if FEY_SCRIPTING
import backend.Script;
#end

import haxe.ds.ReadOnlyArray;

import sys.FileSystem;
#if !NO_FEY_PATHS
import haxe.io.Path;
#end
#if !NO_FEY_FILESYS
import backend.Paths;
#end

class Mod {
  #if FEY_SCRIPTING
  static var scriptPaths:Array<String> = ['scripts'];
  var scripts:Map<String,Script> = [];
  #end

	static var _modList:Array<String> = [];
	public static var modList:ReadOnlyArray<String> = modList;


	public static function reload() {
		_modList.resize(0);
		ensureMods();
		FileSystem.readDirectory('mods')
			.map(f -> 'mods/$f')
			.filter(f -> FileSystem.isDirectory('$f'))
			.map(f -> _modList.push(Path.withoutDirectory(f)));
	}

	static function ensureMods() {
		#if FEY_FILESYS
		FileSys.makedir('mods', false);
		#else
		if (!FileSystem.exists('mods'))
			FileSystem.makeDirectory('mods');
		#end
	}
}
#end
