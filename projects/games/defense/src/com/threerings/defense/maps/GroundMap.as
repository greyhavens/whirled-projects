package com.threerings.defense.maps {

import flash.display.BitmapData;
import flash.geom.Point;

import com.threerings.defense.Board;

/**
 * Map of the level ground, specifying reserved and impassable tiles.
 */
public class GroundMap extends Map
{
    public static const SOURCE_MASK :uint = 0x00808080;
    public static const TARGET_MASK :uint = 0x00404040;
    
    public static const INVALID_PIXEL :uint = 0xff000000;
    public static const RESERVED_PIXEL :uint = 0x0f000000;
    public static const PLAYER_SOURCE_PIXELS :Array =
        [ Board.PLAYER_COLORS[0] & SOURCE_MASK,
          Board.PLAYER_COLORS[1] & SOURCE_MASK ];
    
    public static const PLAYER_TARGET_PIXELS :Array =
        [ Board.PLAYER_COLORS[0] & TARGET_MASK,
          Board.PLAYER_COLORS[1] & TARGET_MASK ];

    public function loadDefinition (id :int, playerCount :int) :void
    {
        trace("LOAD DEF: LEVEL: " + id + ", PLAYER COUNT: " + playerCount);
        _sources = new Array(playerCount);
        _targets = new Array(playerCount);
        
        var data :BitmapData = MapFactory.makeGroundMapData(id, playerCount);

        if (data.width != _width || data.height != _height) {
            throw new Error("Invalid ground map for id: " + id + ", player count: " + playerCount);
        }
        
        data.lock();
        for (var xx :int = 0; xx < _width; xx++) {
            for (var yy :int = 0; yy < _height; yy++) {
                var p :uint = data.getPixel32(xx, yy);
                if (p != 0x00000000) {
                    processPixel(xx, yy, p);
                }
            }
        }
        data.unlock();

        invalidate();
    }

    public function getPlayerSource (playerIndex :int) :Point
    {
        return _sources[playerIndex] as Point;
    }
        
    public function getPlayerTarget (playerIndex :int) :Point
    {
        return _targets[playerIndex] as Point;
    }
        
    protected function processPixel (x :int, y :int, p :uint) :void
    {
        if (p == INVALID_PIXEL) {
            _data[x][y] = INVALID;
        } else if (p == RESERVED_PIXEL) {
            _data[x][y] = RESERVED; 
        } else if ((p & SOURCE_MASK) != 0) {
            processSpecial(x, y, _sources, PLAYER_SOURCE_PIXELS.indexOf(p & SOURCE_MASK));
        } else if ((p & TARGET_MASK) != 0) {
            processSpecial(x, y, _targets, PLAYER_TARGET_PIXELS.indexOf(p & TARGET_MASK));
        }
    }

    protected function processSpecial (x :int, y :int, array :Array, playerIndex :int) :void
    {
        if (playerIndex == -1) {
            throw new Error("Invalid special pixel found at position " + x + ", " + y);
        } else {
            array[playerIndex] = new Point(x, y);
        }
    }

    /** Contains default critter sources, indexed by player index */
    protected var _sources :Array; // of Point
        
    /** Contains default critter targets, indexed by player index */
    protected var _targets :Array; // of Point
}
}
