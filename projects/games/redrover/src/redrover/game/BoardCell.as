package redrover.game {

public class BoardCell
{
    public var gridX :int;
    public var gridY :int;
    public var hasGem :Boolean;

    public static function create (gridX :int, gridY :int) :BoardCell
    {
        var cell :BoardCell = new BoardCell();
        cell.gridX = gridX;
        cell.gridY = gridY;
        return cell;
    }

}

}
