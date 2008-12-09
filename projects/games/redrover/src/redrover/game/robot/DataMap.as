package redrover.game.robot {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;

import redrover.game.*;

public class DataMap
{
    public static function createGemRedemptionMap (board :Board) :DataMap
    {
        var redemptionCells :Array = board.cells.filter(
            function (cell :BoardCell, index :int, arr :Array) :Boolean {
                return cell.isGemRedemption;
            });

        var coords :Array = redemptionCells.map(
            function (cell :BoardCell, index :int, arr :Array) :Vector2 {
                return new Vector2(cell.gridX, cell.gridY);
            });

        return createDistanceMap(board, coords);
    }

    public static function createGemMap (board :Board, gemType :int = -1) :DataMap
    {
        // get the coordinates of all the gem spawners on this board
        var spawners :Array = GemSpawner.getAll().filter(
            function (spawner :GemSpawner, index :int, arr :Array) :Boolean {
                return (spawner.board == board && (gemType < 0 || gemType == spawner.gemType));
            });

        var coords :Array = spawners.map(
            function (spawner :GemSpawner, index :int, arr :Array) :Vector2 {
                return new Vector2(spawner.gridX, spawner.gridY);
            });

        return createDistanceMap(board, coords);
    }

    public static function createDistanceMap (board :Board, startCellCoords :Array) :DataMap
    {
        var map :DataMap = new DataMap(
            ArrayUtil.create(board.cells.length, Number.MAX_VALUE),
            board.cols, board.rows);

        // flood-fill the map with the minimum distance to each start cell
        for each (var startCellCoord :Vector2 in startCellCoords) {
            visitCell(startCellCoord.x, startCellCoord.y, 0);
        }

        function visitCell (x :int, y :int, distance :Number) :void
        {
            var boardCell :BoardCell = board.getCell(x, y);
            if (boardCell == null || boardCell.isObstacle || map.getValue(x, y) <= distance) {
                return;
            }

            map.setValue(x, y, distance);
            visitCell(x + 1, y, distance + 1);
            visitCell(x - 1, y, distance + 1);
            visitCell(x, y + 1, distance + 1);
            visitCell(x, y - 1, distance + 1);
        }

        return map;
    }

    public function getValue (x :int, y :int) :Number
    {
        if (x >= 0 && x < _cols && y >= 0 && y < _rows) {
            return _cells[(y * _cols) + x];
        } else {
            return 0;
        }
    }

    public function setValue (x :int, y :int, val :Number) :void
    {
        if (x >= 0 && x < _cols && y >= 0 && y < _rows) {
            _cells[(y * _cols) + x] = val;
        }
    }

    public function DataMap (cells :Array, cols :int, rows :int)
    {
        _cells = cells;
        _cols = cols;
        _rows = rows;
    }

    protected var _cells :Array;
    protected var _cols :int;
    protected var _rows :int;
}

}
