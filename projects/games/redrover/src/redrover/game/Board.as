package redrover.game {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.SimObject;

import redrover.*;

public class Board extends SimObject
{
    public function Board (teamId :int, cols :int, rows :int, terrain :Array)
    {
        _teamId = teamId;
        _cols = cols;
        _rows = rows;
        _cellSize = GameContext.levelData.cellSize;
        _cellSizeInv = 1 / _cellSize;

        var size :int = _cols * _rows;
        _cells = ArrayUtil.create(size);
        for (var ii :int = 0; ii < size; ++ii) {
            var terrainType :int = terrain[ii];
            var isObstacle :Boolean = (terrainType == Constants.TERRAIN_OBSTACLE);
            var isGemRedemption :Boolean = (terrainType == Constants.TERRAIN_GEMREDEMPTION);
            var moveSpeed :Number = (terrainType == Constants.TERRAIN_SLOW ?
                GameContext.levelData.slowTerrainSpeedMultiplier : 1);
            _cells[ii] = new BoardCell(getX(ii), getY(ii), isObstacle, isGemRedemption, moveSpeed);
        }
    }

    public function countGems () :int
    {
        var numGems :int;
        for each (var cell :BoardCell in _cells) {
            if (cell.hasGem) {
                numGems++;
            }
        }

        return numGems;
    }

    public function get teamId () :int
    {
        return _teamId;
    }

    public function get cellSize () :Number
    {
        return _cellSize;
    }

    public function get pixelWidth () :int
    {
        return _cols * _cellSize;
    }

    public function get pixelHeight () :int
    {
        return _rows * _cellSize;
    }

    public function get cols () :int
    {
        return _cols;
    }

    public function get rows () :int
    {
        return _rows;
    }

    public function get cells () :Array
    {
        return _cells;
    }

    public function getCell (gridX :int, gridY :int) :BoardCell
    {
        return (gridX >= 0 && gridX < _cols && gridY >= 0 && gridY < _rows ?
            _cells[getIndex(gridX, gridY)] : null);
    }

    public function getCellAtPixel (x :Number, y :Number) :BoardCell
    {
        return getCell(x * _cellSizeInv, y * _cellSizeInv);
    }

    protected function getIndex (x :int, y :int) :int
    {
        return (y * _cols) + x;
    }

    protected function getX (index :int) :int
    {
        return (index % _cols);
    }

    protected function getY (index :int) :int
    {
        return (index / _cols);
    }

    protected var _teamId :int;
    protected var _cols :int;
    protected var _rows :int;
    protected var _cells :Array;

    protected var _cellSize :Number;
    protected var _cellSizeInv :Number;
}

}
