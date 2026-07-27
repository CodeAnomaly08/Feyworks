package objects;

import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxTilemap;

typedef AutoTileProfile = Array<{
	pattern:Array<Int>,
	tiles:Array<Int>,
	rotations:Int,
	rotationStep:Int
}>;

class Tilemap extends FlxTilemap {
	static var defaultAutoTile:AutoTileProfile = [
		// I'll proceed with the assumption that (tile facing UP) is the default, and rotate clockwise
		{
			pattern: [1, 1, 1, 1, 1, 1, 1, 1], // full block
			tiles: [1],
			rotations: 1,
			rotationStep: 0
		},
		{
			pattern: [0, 2, 1, 1, 1, 1, 1, 2], // walls
			tiles: [27, 18, 11, 20],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [0, 2, 0, 2, 1, 1, 1, 2], // outer corner
			tiles: [9, 17, 16, 8],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [1, 0, 1, 1, 1, 1, 1, 1], // inner corner
			tiles: [26, 10, 12, 28],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [1, 2, 0, 2, 1, 2, 0, 2], // vertical straight
			tiles: [13],
			rotations: 1,
			rotationStep: 0
		},
		{
			pattern: [0, 2, 1, 2, 0, 2, 1, 2], // horizontal straight
			tiles: [3],
			rotations: 1,
			rotationStep: 0
		},
		{
			pattern: [0, 2, 1, 2, 0, 2, 0, 2], // horizontal straight end
			tiles: [2, 4],
			rotations: 2,
			rotationStep: 4
		},
		{
			pattern: [0, 2, 0, 2, 1, 2, 0, 2], // vertical straight end
			tiles: [5, 21],
			rotations: 2,
			rotationStep: 4
		},
		{
			pattern: [0, 2, 0, 2, 1, 0, 1, 2], // inner corner outer corner
			tiles: [37, 45, 44, 36],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [0, 2, 1, 0, 1, 0, 1, 2], // double inner corner wall
			tiles: [46, 38, 39, 47],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [0, 2, 1, 0, 1, 1, 1, 2], // righthand inner corner wall
			tiles: [7, 22, 30, 15],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [0, 2, 1, 1, 1, 0, 1, 2], // lefthand inner corner wall
			tiles: [6, 23, 31, 14],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [1, 0, 1, 1, 1, 1, 1, 0], // double inner corners
			tiles: [24, 25, 33, 32],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [1, 0, 1, 1, 1, 0, 1, 1], // double diagonal inner corners
			tiles: [41, 40],
			rotations: 2,
			rotationStep: 2
		},
		{
			pattern: [1, 0, 1, 0, 1, 1, 1, 0], // triple inner corners
			tiles: [35, 43, 42, 34],
			rotations: 4,
			rotationStep: 2
		},
		{
			pattern: [1, 0, 1, 0, 1, 0, 1, 0], // four inner corners
			tiles: [19],
			rotations: 1,
			rotationStep: 0
		},
		{
			pattern: [0, 2, 0, 2, 0, 2, 0, 2], // full circle
			tiles: [29],
			rotations: 1,
			rotationStep: 0
		},
	];

	public function getNeighbors(tileX:Int, tileY:Int, filledCorners:Bool = true) {
		return [
			getTileIndex(tileX, tileY - 1),
			getTileIndex(tileX + 1, tileY - 1),
			getTileIndex(tileX + 1, tileY),
			getTileIndex(tileX + 1, tileY + 1),
			getTileIndex(tileX, tileY + 1),
			getTileIndex(tileX - 1, tileY + 1),
			getTileIndex(tileX - 1, tileY),
			getTileIndex(tileX - 1, tileY - 1),
		].map(f -> f == -1 ? (filledCorners ? 1 : 0) : (f>=_collideIndex?1:0));
	}

	public inline function countNeighbors(tileX:Int, tileY:Int, filledCorners:Bool = true) {
		return getNeighbors(tileX, tileY, filledCorners).filter(f -> f > 0).length;
	}

	function getTileState(profile:AutoTileProfile, tileX:Int, tileY:Int, filledCorners:Bool = true) {
		var neighbors = getNeighbors(tileX, tileY, filledCorners);
		for (pattern in profile) {
			var curRot = 0;
			var template = pattern.pattern.copy();
			for (rotation in 0...pattern.rotations) {
				var valid = true;
				for (i => tile in template)
					if (neighbors[i] != tile && tile != 2) {
						valid = false;
						break;
					}
				if (valid)
					return pattern.tiles[curRot];
				curRot++;
				for (step in 0...pattern.rotationStep)
					template.unshift(template.pop());
			}
		}
		return -1;
	}

	public function feyAutoTile(?profile:AutoTileProfile, tileIndex:Int = 1)
		for (i in getAllMapIndices(tileIndex)) {
			var state = getTileState(profile ?? defaultAutoTile, getColumn(i), getRow(i));
			if (state < 0)
				trace('Invalid state! $state at ${getColumn(i)},${getRow(i)}');
			setTileIndex(i, state);
		}

	public function loadMapFromSize(width:Int, height:Int, fillTile:Int = 0, ?graphic:FlxTilemapGraphicAsset, ?tileWidth:Int, ?tileHeight:Int,
			?autoTile:FlxTilemapAutoTiling, ?startingIndex:Int, ?drawIndex:Int, ?collideIndex:Int) {
		return loadMapFromArray([for (_ in 0...width * height) fillTile], width, height, graphic ?? this.graphic, tileWidth ?? this.tileWidth,
			tileHeight ?? this.tileHeight, autoTile ?? auto, startingIndex ?? _startingIndex, drawIndex ?? _drawIndex, collideIndex ?? _collideIndex);
	}

	// fills an area with a tile index.
	public function fill(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, tile:Int = 0) {
		width = width > 0 ? width : widthInTiles - x;
		height = height > 0 ? height : heightInTiles - y;
		// most simplest version of this for now. I'm sure there'll be a better way to do this, but not now.
		for (xpos in (x...(x + width)))
			for (ypos in (y...(y + height))) {
				setTileIndex(xpos, ypos, tile);
			}
	}
}
