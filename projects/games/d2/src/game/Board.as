package game {

import flash.geom.Point;

import def.BoardDefinition;

import units.Tower;

import maps.GroundMap;
import maps.Map;
import maps.PathMap;

import com.threerings.util.HashMap;

/**
 * Encapsulates an instantiated game board, based on definition.
 */
public class Board
    implements UnloadListener
{

    // todo: factor me out, along with board loading from pngs
    public static const PLAYER_COLORS :Array = [ 0x000000ff /* player 0 */,
                                                 0x0000ff00 /* player 1 */ ];


    public function Board (main :Main, def :BoardDefinition)
    {
        _main = main;
        _def = def;

        _allmaps = new Array();

        _groundmap = new GroundMap(this);
        _allmaps.push(_groundmap);

        var count :int = _main.playerCount;
        _pathmaps = new Array(count);
        for (var ii :int = 0; ii < count; ii++) {
            _pathmaps[ii] = new PathMap(this, ii);
            _allmaps.push(_pathmaps[ii]);
        }

        for each (var m :Map in _allmaps) {
            m.clear();
        }

        trace("BOARD INITIALIZED!");
        
    }

    public function get def () :BoardDefinition { return _def; }
    public function get columns () :int { return _def.squares.x; }
    public function get rows () :int { return _def.squares.y; }
    public function get boardWidth () :int { return _def.pixelsize.x; }
    public function get boardHeight () :int { return _def.pixelsize.y; }
    public function get tileWidth () :int { return int(boardWidth / columns); }
    public function get tileHeight () :int { return int(boardHeight / rows); }

    public function get rounds () :int { return 1; } // todo: factor me out
    
    // from interface UnloadListener
    public function handleUnload () :void
    {
        trace("UNLOADING BOARD");
    }

    public function processMaps () :void
    {
        for each (var map :Map in _allmaps) {
            map.update();
        }
    }

    public function roundStarted () :void
    {
        trace ("BOARD: ROUND STARTED");
            
        // reset everything
        for each (var m :Map in _allmaps) {
            m.clear();
        }

        // initialize the ground map
        _groundmap.loadDefinition(this, _main.playerCount);

        // and based on that, the pathfinding maps
        for (var ii :int = 0; ii < _main.playerCount; ii++) {
            var t :Point = getPlayerTarget(ii);
            (_pathmaps[ii] as PathMap).setTarget(t.x, t.y);
        }
    }

    public function roundEnded () :void
    {
        trace ("BOARD: ROUND ENDED");
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
                tower.pos.x + tower.width <= columns && tower.pos.y + tower.height <= rows);
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
        return new Point(int(index / rows), int(index % rows));
    }

    public function towerPositionToIndex (x :int, y :int) :int
    {
        return y * rows + x;
    }

    public function getMapOccupancy () :GroundMap
    {
        return _groundmap;
    }

    public function getPathMap (player :int) :PathMap
    {
        return _pathmaps[player];
    }

    /**
     * Converts screen coordinates (relative to the upper left corner of the board)
     * to logical coordinates in board space. Rounds results down to integer coordinates.
     */
    public function screenToLogicalPosition (x :Number, y :Number) :Point
    {
        return new Point(int(Math.floor(x / tileWidth)),
                         int(Math.floor(y / tileHeight)));
    }


    protected var _main :Main;
    protected var _def :BoardDefinition;

    /** Various game-related maps. */
    protected var _groundmap :GroundMap;
    protected var _pathmaps :Array; // of PathMap, indexed by player
    protected var _allmaps :Array; // of Map;
    
    /** Hash map of all towers, indexed by their id. */
    protected var _towers :HashMap = new HashMap();

}
}
