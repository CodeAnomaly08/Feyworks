package backend;
#if (FEY_FILESELECT)

import backend.Logging;
import lime.ui.FileDialog;

enum abstract FileSelectMode(Int) {
	var OPEN;
	var SAVE;
	var FOLDER;
}

private typedef FileSelectConfig = {
	?filters:String,
	?path:String,
	?title:String,
}

/**
	Class for selecting file paths.
	Example usage:
	```haxe
	FileSelect.single(path->{trace('Selected file: $path')}); // select a single file
	FileSelect.single(path->{trace('Selected path: $path')},1); // select a path to save to
	FileSelect.single(path->{trace('Selected folder: $path')},2); // select a folder path

	FileSelect.single({filters:'.png'},path->trace('Selected file: $path')); // select only .png files

	  FileSelect.multiple(paths->trace('Selected files: ${paths.join(', ')}')); // select files in bulk
	```
	  Disable via haxedef `FEY_NO_FILESELECT`
**/
class FileSelect {
	public static var ready:Bool = true;
	static var dialog:FileDialog = {
		var tmp = new FileDialog();
		tmp.onCancel.add(() -> {
			dialog.onSelect.removeAll();
			dialog.onSelectMultiple.removeAll();
			ready = true;
		});
		tmp;
	};

	/**
		Select a single path.
	**/
	public static function single(?config:FileSelectConfig = null, callback:String->Void, mode:FileSelectMode = OPEN) {
		if (!ready) {
			Logging.warn('Couldn\'t open file dialog: Another dialog is already open');
			return;
		};
		ready = false;
		var title = mode == OPEN ? 'Select a File' : mode == SAVE ? 'Select a Path to save' : 'Select a Folder';
		var config = config ?? {filters: '', path: '', title: title};
		dialog.onSelect.add(s -> {
			dialog.onSelect.removeAll();
			ready = true;
			try {
				callback(s);
			} catch (e) {
				Logging.error(e);
			}
		});
		// isn't it awesome how Haxe can automatically differentiate between my own enum type and the enum type that goes into dialog.browse?
		dialog.browse(mode == OPEN ? OPEN : mode == SAVE ? SAVE : OPEN_DIRECTORY, config.filters, config.path, config.title ?? title);
	}

	/**
		Select multiple file paths, in bulk.
	**/
	public static function multiple(config:FileSelectConfig, callback:Array<String>->Void) {
		if (!ready) {
			Logging.warn('Couldn\'t open file dialog: Another dialog is already open');
			return;
		};
		ready = false;
		var config = config ?? {filters: '', path: '', title: 'Select a File'};
		dialog.onSelectMultiple.add(s -> {
			dialog.onSelectMultiple.removeAll();
			ready = true;
			try {
				callback(s);
			} catch (e) {
				Logging.error(e);
			}
		});
		dialog.browse(OPEN_MULTIPLE, config.filters, config.path, config.title ?? 'Select Files');
	}
}
#end
