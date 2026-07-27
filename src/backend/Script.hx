#if FEY_SCRIPTING
package backend;

import haxe.io.Path;
#if FEY_FILESYS
import backend.FileSys;
#else

import sys.io.File;
import sys.FileSystem;
#end
#if FEY_HSCRIPT
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;
#end
#if FEY_LUA
import lscript.LScript;
#end

#if !FEY_SINGLE_SCRIPT_LANGUAGE
enum ScriptType {
	#if FEY_LUA
	LUA;
	#end
	#if FEY_HSCRIPT
	HSCRIPT;
	#end
}
#end

class Script {
	#if !FEY_SINGLE_SCRIPT_LANGUAGE
	var type:ScriptType;
	#if FEY_LUA
	var lscript:LScript;
	#end
	#if FEY_HSCRIPT
	var hscript:Iris;
	#end
	#else
	var script:#if FEY_LUA_ONLY LScript; #end

	#if FEY_HSCRIPT_ONLY Iris; #end
	#end
	public function new(#if !FEY_SINGLE_SCRIPT_LANGUAGE type:ScriptType #end, contents:String, ?name:String) {
		#if !FEY_SINGLE_SCRIPT_LANGUAGE
		this.type = type;
		switch (type) {
			#if FEY_LUA
			case LUA:
				lscript = new LScript(contents);
				lscript.execute();
			#end
			#if FEY_HSCRIPT
			case HSCRIPT:
				hscript = new Iris(contents, new IrisConfig(name, true, true));
			#end
		}
		#else
		script = #if FEY_LUA_ONLY new LScript(contents);
			script.execute(); #end
		#if FEY_HSCRIPT_ONLY
		new Iris(contents, new IrisConfig(name, true, true));
		#end
		#end
	}

  static function loadContents(path:String){
		#if FEY_FILESYS
		return FileSys.read(path);
		#else
		return FileSystem.exists(path) ? File.getContent(path) : '';
		#end
  }

	#if (FEY_LUA && !FEY_LUA_ONLY)
	public static function fromLuaFile(path:String) {
		return new Script(LUA, loadContents(path));
	}
	#end

	#if (FEY_HSCRIPT && !FEY_HSCRIPT_ONLY)
	public static function fromHXFile(path:String) {
		return new Script(HSCRIPT, loadContents(path));
	}
	#end

	public static function fromFile(path:String) {
		#if !FEY_SINGLE_SCRIPT_LANGUAGE
		return switch (Path.extension(path)) {
			#if FEY_LUA
			case 'lua':
				fromLuaFile(path);
			#end
			#if FEY_HSCRIPT
			case 'hx':
				fromHXFile(path);
			#end
			default:
				Logging.warn('Could not load script from $path: Not a recognized script type!');
				throw 'Could not load script from $path: Not a recognized script type!';
		}
		#else
		return new Script(loadContents(path));
		#end
	}

	public function getVar(name:String) {
		#if !FEY_SINGLE_SCRIPT_LANGUAGE
		return switch (type) {
			case LUA:
				lscript.getVar(name);
			case HSCRIPT:
				hscript.get(name);
		}
		#end
		#if FEY_LUA_ONLY
		return script.getVar(name)
		#end
		#if FEY_HSCRIPT_ONLY
		return script.get(name);
		#end
	}

	public function setVar(name:String, value:Dynamic) {
		#if !FEY_SINGLE_SCRIPT_LANGUAGE
		return switch (type) {
			case LUA:
				lscript.setVar(name,value);
			case HSCRIPT:
				hscript.set(name,value);
		}
		#end
		#if FEY_LUA_ONLY
		return script.setVar(name,value)
		#end
		#if FEY_HSCRIPT_ONLY
		return script.set(name,value);
		#end
	}

	public function callFunction(name:String, ?args:Array<Dynamic>) {
		#if !FEY_SINGLE_SCRIPT_LANGUAGE
		return switch (type) {
			case LUA:
				lscript.callFunc(name, args);
			case HSCRIPT:
				hscript.call(name, args);
		}
		#end
		#if FEY_LUA_ONLY
		return script.callFunc(name, args);
		#end
		#if FEY_HSCRIPT_ONLY
		return script.call(name, args);
		#end
	}

	public function toString() {
		#if !FEY_SINGLE_SCRIPT_LANGUAGE
		return 'Script($type)';
		#else
		return 'Script';
		#end
	}
}
#end
