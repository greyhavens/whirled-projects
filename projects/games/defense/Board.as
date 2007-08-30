package {

import flash.events.Event;
import flash.geom.Point;

import com.threerings.util.HashMap;

import com.whirled.WhirledGameControl;

/**
 * Game board, which can be queried for information about static board definition,
 * as well as positions of the different pieces.
 */
public class Board
{
    public static const WIDTH :int = 30;
    public static const HEIGHT :int = 20;

    public static const SQUARE_WIDTH :int = 20;
    public static const SQUARE_HEIGHT :int = 20;
    public static const PIXEL_WIDTH :int = 600;  // WIDTH * SQUARE_WIDTH
    public static const PIXEL_HEIGHT :int = 400; // HEIGHT * SQUARE_HEIGHT

    public static const PLAYER_COLORS :Array = [ 0x000000ff /* player 0 */,
                                                 0x0000ff00 /* player 1 */ ];
    
    public function Board (whirled :WhirledGameControl)
    {
        _whirled = whirled;
        _groundmap = new GroundMap(WIDTH, HEIGHT);
    }

    public function getMyPlayerIndex () :int
    {
        return _whirled.seating.getMyPosition();
    }

    public function getMyColor () :uint
    {
        return PLAYER_COLORS[getMyPlayerIndex()];
    }

    public function getPlayerCount () :uint
    {
        return _whirled.seating.getPlayerIds().length;
    }
    
    public function handleUnload (event : Event) :void
    {
        trace("BOARD UNLOAD");
    }

    public function reset () :void
    {
        var mapId :int = 1; // todo
        _groundmap.loadDefinition(mapId, getPlayerCount());
    }
    
    // Functions used by game logic to mark / clear towers on the board

    public function markAsOccupied (def :TowerDef, playerId :int) :void
    {
        _groundmap.fillAllTowerCells(def, playerId);
    }
    
    public function isUnoccupied (def :TowerDef) :Boolean
    {
        return _groundmap.isEachTowerCellEqual(def, Map.UNOCCUPIED);
    }

    public function isOnBoard (def :TowerDef) :Boolean
    {
        return (def.x >= 0 && def.y >= 0 &&
                def.x + def.width <= WIDTH && def.y + def.height <= HEIGHT);
    }

    public function getPlayerSource (playerIndex :int) :Point
    {
        return _groundmap.getPlayerSource(playerIndex);
    }
    
    public function getPlayerTarget (playerIndex :int) :Point
    {
        return _groundmap.getPlayerTarget(playerIndex);
    }

    public function towerIndexToPosition (index :int) :Point
    {
        return new Point(int(index / HEIGHT), int(index % HEIGHT));
    }

    public function towerPositionToIndex (x :int, y :int) :int
    {
        return x * HEIGHT + y;
    }
    
    /**
     * Converts screen coordinates (relative to the upper left corner of the board)
     * to logical coordinates in board space.
     */
    public static function screenToLogicalPosition (x :int, y :int) :Point
    {
        return new Point(int(Math.floor(x / SQUARE_WIDTH)), int(Math.floor(y / SQUARE_HEIGHT)));
    }

    /**
     * Converts board coordinates to screen coordinates (relative to upper left corner).
     */
    public static function logicalToScreenPosition (x :int, y :int) :Point
    {
        return new Point(x * SQUARE_WIDTH, y * SQUARE_HEIGHT);
    }


    /** Various game-related maps. */
    protected var _groundmap :GroundMap;
    
    /** Hash map of all towers, indexed by their id. */
    protected var _towers :HashMap = new HashMap();

    /** This is where we get game settings from. */
    protected var _whirled :WhirledGameControl;
}
}
