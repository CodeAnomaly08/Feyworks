package backend;

import haxe.io.Bytes;
import backend.Logging;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

/**
	Class for IO procedures.
	Disable via haxedef `FEY_NO_FILESYS`
**/
class FileSys {
	public static inline function exists(path:String)
		return FileSystem.exists(path);

	public static inline function isDirectory(path:String)
		return FileSystem.isDirectory(path);

	public static inline function isFile(path:String)
		return exists(path) && !isDirectory(path);

	/**
		Returns the contents of a folder as a string array. Returns an empty array if the given path is not a folder.
	**/
	public static function listDirectory(path:String, fullPath:Bool = false) {
		if (isDirectory(path))
			return {
				var p = FileSystem.readDirectory(path);
				fullPath ? p.map(f -> Path.join([path, f])) : p;
			};
		return {
			Logging.warn('Invalid directory path $path: Not a directory');
			[];
		};
	}

	/**
		Returns the contents of a file. Returns an empty string if the given path is not a file.
		Does not work on folders, use `listDirectory` to get the contents of a folder.
	**/
	public static function read(path:String) {
		if (!isFile(path))
			return {
				Logging.warn('Invalid file path $path: Not a file');
				'';
			};
		return File.getContent(path);
	}

	/**
		Returns the contents of a file. Returns empty string bytes if the given path is not a file.
		Does not work on folders, use `listDirectory` to get the contents of a folder.
	**/
	public static function readBytes(path:String) {
		if (!isFile(path))
			return {
				Logging.warn('Invalid file path $path: Not a file');
				Bytes.ofString('');
			};
    return File.getBytes(path);
	}

	/**
		Creates a directory. Fails if there is already a file or folder at the desired path.
		This method is recursive; the parent directories don't have to exist.
	**/
	public static function makedir(path:String, warnExisting:Bool = true) {
		if (exists(path)) {
			return Logging.warn('Unable to create folder $path: Folder or file already exists with this name!');
		}
		return FileSystem.createDirectory(path);
	}

	/**
		Creates or saves to a file. Fails if there is a folder at the desired path.
		This method is recursive; the parent directories don't have to exist.
	**/
	public static function write(path:String, contents:String) {
		if (!isDirectory(Path.directory(path))) {
			makedir(Path.directory(path));
		}
		if (!isDirectory(path))
			return File.saveContent(path, contents);
		return Logging.warn('Unable to write to $path: Path leads to a folder');
	}

	/**
		Delete a file or folder. Use `recursive` to delete all the contents of a folder.
		If not using `recursive`, attempting to delete a folder with items will not work.
	**/
	public static function delete(path:String, recursive:Bool = false):Void {
		if (isDirectory(path))
			if (recursive)
				for (subpath in listDirectory(path))
					delete(Path.join([path, subpath]), true);
			else if (listDirectory(path).length == 0)
				return FileSystem.deleteDirectory(path);
			else
				return Logging.warn('Cannot delete folder $path: Contains files. Did you mean to enable `recursive`?');
		if (isFile(path))
			return FileSystem.deleteFile(path);
		return Logging.warn('Invalid path $path: Doesn\'t exist');
	}
}