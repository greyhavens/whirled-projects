package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

import redrover.*;
import redrover.game.*;
import redrover.util.*;

public class BoardView extends SceneObject
{
    public function BoardView (board :Board)
    {
        _board = board;
        _sprite = SpriteUtil.createSprite();

        var g :Graphics = _sprite.graphics;
        g.beginFill(TEAM_COLORS[board.teamId]);
        g.drawRect(0, 0, _board.pixelWidth, _board.pixelHeight);
        g.endFill();

        g.lineStyle(2, 0);
        for (var xx :int = 1; xx < _board.cols; ++xx) {
            g.moveTo(xx * Constants.BOARD_CELL_SIZE, 0);
            g.lineTo(xx * Constants.BOARD_CELL_SIZE, _board.pixelHeight);
        }
        for (var yy :int = 1; yy < _board.rows; ++yy) {
            g.moveTo(0, yy * Constants.BOARD_CELL_SIZE);
            g.lineTo(_board.pixelWidth, yy * Constants.BOARD_CELL_SIZE);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _board :Board;
    protected var _sprite :Sprite;

    protected static const TEAM_COLORS :Array = [ 0xFF0000, 0x0000FF ];
}

}
