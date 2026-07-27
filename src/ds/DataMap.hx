package ds;

import flixel.util.FlxArrayUtil;

// like a tilemap, but no graphics, position or collision, just pure data.
class DataMap {
	var _data;

	public var widthInTiles:Int;
	public var heightInTiles:Int;

	public function loadMapFromArray(arr:Array<Int>, widthInTiles:Int, heightInTiles:Int) {
		this.widthInTiles = widthInTiles;
		this.heightInTiles = heightInTiles;
		_data = arr.copy();
	}

	public function loadMapFrom2DArray(arr:Array<Array<Int>>) {
		heightInTiles = arr.length;
		widthInTiles = arr[0].length;
		_data = FlxArrayUtil.flatten2DArray(arr);
	}

  public function loadMapFromSize(width:Int,height:Int,fill:Int){
    loadMapFromArray([for (i in 0...(w*h)) fill],widthInTiles,heightInTiles);
  }

	overload public extern inline function setTileIndex(mapIndex:Int, tileIndex:Int) {
		_data[mapIndex] = data;
	}

	overload public extern inline function setTileIndex(column:Int, row:Int, tileIndex:Int) {
		_data[column + (row * widthInTiles)];
	}
}
