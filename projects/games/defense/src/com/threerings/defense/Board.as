package com.threerings.defense {

import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Point;

import com.threerings.util.HashMap;

import com.whirled.WhirledGameControl;

import com.threerings.defense.maps.GroundMap;
import com.threerings.defense.maps.Map;
import com.threerings.defense.maps.PathMap;
import com.threerings.defense.tuning.LevelDefinitions;
import com.threerings.defense.units.Tower;

/**
 * Game board, which can be queried for information about static board definition,
 * as well as positions of the different pieces.
 */
public class Board
{
    public static const WIDTH :int = 17;
    public static const HEIGHT :int = 22;

    public static const SQUARE_WIDTH :int = 30;
    public static const SQUARE_HEIGHT :int = 20;

    public static const BOARD_WIDTH :int = WIDTH * SQUARE_WIDTH;
    public static const BOARD_HEIGHT :int = HEIGHT * SQUARE_HEIGHT;
        
    public static const BOARD_OFFSETX :int = 40;
    public static const BOARD_OFFSETY :int = 27;
    
    public static const BG_WIDTH :int = 700;
    public static const BG_HEIGHT :int = 500;
    
    public static const PLAYER_COLORS :Array = [ 0x000000ff /* player 0 */,
                                                 0x0000ff00 /* player 1 */ ];

    public static const UI_COLOR_MINE :uint = 0xff3fff00;
    public static const UI_COLOR_THEIRS :uint = 0xffff6600; // 0xff7f7f7f;

    public static const SCOREPANEL_POS :Array = [ new Point(580, 440), new Point(5, 40) ];
    
    /** Level information. */
    public var level :Level; 

    public function Board (whirled :WhirledGameControl, rounds :int)
    {
        _whirled = whirled;
        _rounds = rounds;

        _allmaps = new Array();

        _groundmap = new GroundMap();
        _allmaps.push(_groundmap);

        var count :int = getPlayerCount();
        _pathmaps = new Array(count);
        for (var ii :int = 0; ii < count; ii++) {
            _pathmaps[ii] = new PathMap(this, ii);
            _allmaps.push(_pathmaps[ii]);
        }

        for each (var m :Map in _allmaps) {
            m.clear();
        }
    }

    public function handleUnload (event : Event) :void
    {
        trace("BOARD UNLOAD");
    }

    public function get rounds () :int
    {
        return _rounds;
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

    public function getPlayerNames () :Array
    {
        return _whirled.seating.getPlayerNames();
    }

    public function getPlayerScores () :Array
    {
        return _whirled.get(Monitor.SCORE_SET) as Array;
    }
    
    public function getInitialHealth () :int
    {
        return LevelDefinitions.getStartingHealth(getPlayerCount(), level.number);
    }
    
    public function getInitialMoney () :int
    {
        return LevelDefinitions.getStartingMoney(getPlayerCount(), level.number);
    }

    public function processMaps () :void
    {
        for each (var map :Map in _allmaps) {
            map.update();
        }
    }
    
    public function roundStarted () :void
    {
        // reset everything
        for each (var m :Map in _allmaps) {
            m.clear();
        }

        // initialize the ground map
        _groundmap.loadDefinition(level.number, getPlayerCount());

        // and based on that, the pathfinding maps
        for (var ii :int = 0; ii < getPlayerCount(); ii++) {
            var t :Point = getPlayerTarget(ii);
            (_pathmaps[ii] as PathMap).setTarget(t.x, t.y);
        }
    }

    public function roundEnded () :void
    {
    }
    
    // Functions used by game logic to mark / clear towers on the board

    public function markAsOccupied (tower :Tower) :void
    {
        // mark the main map
        _groundmap.fillAllTowerCells(tower, tower.player);
        // ... and force all pathing maps to get recalculated
        for each (var m :PathMap in _pathmaps) {
            m.fillAllTowerCells(tower, tower.player);
        }
    }
    
    public function markAsUnoccupied (tower :Tower) :void
    {
        // mark the main map
        _groundmap.fillAllTowerCells(tower, Map.UNOCCUPIED);
        // ... and force all pathing maps to get recalculated
        for each (var m :PathMap in _pathmaps) {
            m.fillAllTowerCells(tower, Map.UNOCCUPIED);
        }
    }

    public function isUnoccupied (tower :Tower) :Boolean
    {
        return _groundmap.isEachTowerCellEqual(tower, Map.UNOCCUPIED);
    }

    public function isOnBoard (tower :Tower) :Boolean
    {
        return (tower.pos.x >= 0 && tower.pos.y >= 0 &&
                tower.pos.x + tower.width <= WIDTH && tower.pos.y + tower.height <= HEIGHT);
    }

    public function getPlayerSource (playerIndex :int) :Point
    {
        return _groundmap.getPlayerSource(playerIndex).clone();
    }
    
    public function getPlayerTarget (playerIndex :int) :Point
    {
        return _groundmap.getPlayerTarget(playerIndex).clone();
    }

    public function towerIndexToPosition (index :int) :Point
    {
        return new Point(int(index / HEIGHT), int(index % HEIGHT));
    }

    public function towerPositionToIndex (x :int, y :int) :int
    {
        return x * HEIGHT + y;
    }


    public function getMapOccupancy () :GroundMap
    {
        return _groundmap;
    }

    public function getPathMap (player :int) :PathMap
    {
        return _pathmaps[player];
    }
    
    /** Various game-related maps. */
    protected var _groundmap :GroundMap;
    protected var _pathmaps :Array; // of PathMap, indexed by player
    protected var _allmaps :Array; // of Map;
    
    /** Hash map of all towers, indexed by their id. */
    protected var _towers :HashMap = new HashMap();

    /** This is where we get game settings from. */
    protected var _whirled :WhirledGameControl;

    /** Number of rounds, as specified in game config. */
    protected var _rounds :int;
}
}
