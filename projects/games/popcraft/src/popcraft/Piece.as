package popcraft {

import core.AppObject;
import flash.display.DisplayObject;
import flash.display.Shape;

public class Piece extends AppObject
{
    public function Piece (resourceType :uint)
    {
        _resourceType = resourceType;

        // draw a circle centered on (0, 0)
        _pieceSprite = new Shape();
        _pieceSprite.graphics.beginFill(GameConstants.getResource(_resourceType).color);
        _pieceSprite.graphics.lineStyle(1, 0);
        _pieceSprite.graphics.drawEllipse(-GameConstants.BOARD_CELL_SIZE / 2, -GameConstants.BOARD_CELL_SIZE / 2, GameConstants.BOARD_CELL_SIZE, GameConstants.BOARD_CELL_SIZE);
        _pieceSprite.graphics.endFill();
    }

    override public function get displayObject () :DisplayObject
    {
        return _pieceSprite;
    }

    public function get resourceType () :uint
    {
        return _resourceType;
    }

    protected var _resourceType :uint;
    protected var _pieceSprite :Shape;
}

}
