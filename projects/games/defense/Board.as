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
    public var width :int = 20;
    public var height :int = 15;

    public var squareWidth :int = 20;
    public var squareHeight :int = 20;
    public var pixelWidth :int = width * squareWidth;
    public var pixelHeight :int = height * squareHeight;

    public function Board (whirled :WhirledGameControl)
    {
        _whirled = whirled;
        _gameboard = new Grid(width, height);
    }

    public function get myId () :int
    {
        return _whirled.getMyId();
    }
    
    public function handleUnload (event : Event) :void
    {
        trace("BOARD UNLOAD");
    }

    public function markAsOccupied (def :TowerDef, playerId :int) :void
    {
        _gameboard.fillAllTowerCells(def, playerId);
    }
    
    public function isUnoccupied (def :TowerDef) :Boolean
    {
        return _gameboard.isEachTowerCellEqual(def, Grid.UNOCCUPIED);
    }

    public function isOnBoard (def :TowerDef) :Boolean
    {
        return (def.x >= 0 && def.y >= 0 &&
                def.x + def.width <= width && def.y + def.height <= height);
    }

    /*
    public function getTower (id :int) :Tower
    {
    }

    public function handleAddTower (tower :Tower) :Boolean
    {
    }

    public function handleRemoveTower (tower :Tower) :Boolean
    {
    }
    */
    
    /**
     * Converts screen coordinates (relative to the upper left corner of the board)
     * to logical coordinates in board space.
     */
    public function screenToLogicalPosition (x :int, y :int) :Point
    {
        return new Point(int(Math.floor(x / squareWidth)), int(Math.floor(y / squareHeight)));
    }

    /**
     * Converts board coordinates to screen coordinates (relative to upper left corner).
     */
    public function logicalToScreenPosition (x :int, y :int) :Point
    {
        return new Point(x * squareWidth, y * squareHeight);
    }


    /** Board occupancy map. */
    protected var _gameboard :Grid;
    
    /** Hash map of all towers, indexed by their id. */
    protected var _towers :HashMap = new HashMap();

    /** This is where we get game settings from. */
    protected var _whirled :WhirledGameControl;
}
}
