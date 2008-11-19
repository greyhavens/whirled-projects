package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;

import redrover.*;
import redrover.game.*;
import redrover.util.*;

public class BoardView extends SceneObject
{
    public function BoardView (board :Board)
    {
        _board = board;
        _sprite = SpriteUtil.createSprite(false, true);

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

        _sprite.cacheAsBitmap = true;

        registerListener(_sprite, MouseEvent.CLICK, onMouseDown);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function onMouseDown (e :MouseEvent) :void
    {
        var gridX :int = e.localX / Constants.BOARD_CELL_SIZE;
        var gridY :int = e.localY / Constants.BOARD_CELL_SIZE;
        if (gridX >= 0 && gridX < _board.cols && gridY >= 0 && gridY < _board.rows) {
            GameContext.localPlayer.moveTo(gridX, gridY);
        }
    }

    protected var _board :Board;
    protected var _sprite :Sprite;

    protected static const TEAM_COLORS :Array = [ 0xFF0000, 0x0000FF ];
}

}
