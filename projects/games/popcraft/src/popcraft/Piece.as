package popcraft {

import core.AppObject;
import flash.display.DisplayObject;
import flash.display.Shape;

public class Piece extends AppObject
{
    public function Piece (resourceType :uint, boardIndex :int)
    {
        _pieceSprite = new Shape();
        this.resourceType = resourceType;

        _boardIndex = boardIndex;
    }

    // from AppObject
    override public function get displayObject () :DisplayObject
    {
        return _pieceSprite;
    }

    public function get boardIndex () :int
    {
        return _boardIndex;
    }

    public function set boardIndex (newIndex :int) :void
    {
        _boardIndex = newIndex;
    }

    public function get resourceType () :uint
    {
        return _resourceType;
    }

    public function set resourceType (newType :uint) :void
    {
        _resourceType = newType;

        // draw a circle centered on (0, 0)
        _pieceSprite.graphics.clear();
        _pieceSprite.graphics.beginFill(GameConstants.getResource(_resourceType).color);
        _pieceSprite.graphics.lineStyle(1, 0);
        _pieceSprite.graphics.drawEllipse(-GameConstants.BOARD_CELL_SIZE / 2, -GameConstants.BOARD_CELL_SIZE / 2, GameConstants.BOARD_CELL_SIZE, GameConstants.BOARD_CELL_SIZE);
        _pieceSprite.graphics.endFill();
    }

    protected var _boardIndex :int;

    protected var _resourceType :uint;
    protected var _pieceSprite :Shape;
}

}
