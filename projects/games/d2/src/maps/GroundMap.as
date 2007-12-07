package maps {

import flash.display.BitmapData;
import flash.geom.Point;

import com.threerings.util.Assert;

import game.Board;

import def.SpecialTileDefinition;

/**
 * Map of the level ground, specifying reserved and impassable tiles.
 */
public class GroundMap extends Map
{
    public function GroundMap (board :Board)
    {
        super(board);
    }
    
    public function initializeTerrain (board :Board) :void
    {
        trace("LOAD DEF: BOARD: " + board);

        for each (var tile :SpecialTileDefinition in board.def.specialTiles) {
                
            var x :int = int(tile.pos.x);
            var y :int = int(tile.pos.y);
                
            switch (tile.typeName) {
            case SpecialTileDefinition.TYPE_RESERVED:
                _data[x][y] = RESERVED;
                break;
            case SpecialTileDefinition.TYPE_INVALID:
                _data[x][y] = INVALID;
                break;
            default:
                Assert.fail("GroundMap doesn't know how to handle special tile " + tile.typeName);
            }
        }
        
        invalidate();
    }

}
}
