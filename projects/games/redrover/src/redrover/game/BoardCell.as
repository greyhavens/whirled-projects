package redrover.game {

import redrover.*;

public class BoardCell
{
    public var gridX :int;
    public var gridY :int;
    public var hasGem :Boolean;

    public function get pixelX () :int
    {
        return gridX * Constants.BOARD_CELL_SIZE;
    }

    public function get pixelY () :int
    {
        return gridY * Constants.BOARD_CELL_SIZE;
    }

    public static function create (gridX :int, gridY :int) :BoardCell
    {
        var cell :BoardCell = new BoardCell();
        cell.gridX = gridX;
        cell.gridY = gridY;
        return cell;
    }

}

}
