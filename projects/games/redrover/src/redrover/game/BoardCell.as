package redrover.game {

import redrover.*;

public class BoardCell
{
    public function BoardCell (gridX :int, gridY :int) :void
    {
        _gridX = gridX;
        _gridY = gridY;
    }

    public function takeGem () :int
    {
        var gemType :int = _gemType;
        _gemType = -1;
        return gemType;
    }

    public function addGem (type :int) :void
    {
        _gemType = type;
    }

    public function get hasGem () :Boolean
    {
        return _gemType >= 0;
    }

    public function get gemType () :int
    {
        return _gemType;
    }

    public function get gridX () :int
    {
        return _gridX;
    }

    public function get gridY () :int
    {
        return _gridY;
    }

    public function get pixelX () :int
    {
        return _gridX * Constants.BOARD_CELL_SIZE;
    }

    public function get pixelY () :int
    {
        return _gridY * Constants.BOARD_CELL_SIZE;
    }

    public var _gridX :int;
    public var _gridY :int;
    public var _gemType :int = -1;
}

}
