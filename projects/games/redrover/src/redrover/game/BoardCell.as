package redrover.game {

import redrover.*;

public class BoardCell
{
    public function BoardCell (gridX :int, gridY :int, isObstacle :Boolean,
        isGemRedemption :Boolean, moveSpeed :Number) :void
    {
        _gridX = gridX;
        _gridY = gridY;
        _isObstacle = isObstacle;
        _isGemRedemption = isGemRedemption;
        _moveSpeed = moveSpeed;
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

    public function get isObstacle () :Boolean
    {
        return _isObstacle;
    }

    public function get isGemRedemption () :Boolean
    {
        return _isGemRedemption;
    }

    public function get moveSpeed () :Number
    {
        return _moveSpeed;
    }

    protected var _gridX :int;
    protected var _gridY :int;
    protected var _isObstacle :Boolean;
    protected var _isGemRedemption :Boolean;
    protected var _moveSpeed :Number;
    protected var _gemType :int = -1;
}

}
