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
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (GameContext.localPlayerTeam != _showingTeam) {
            showTeam(GameContext.localPlayerTeam);
        }
    }

    protected function showTeam (teamId :int) :void
    {
        _showingTeam = teamId;

        var g :Graphics = _sprite.graphics;
        g.clear();
        g.beginFill(TEAM_COLORS[teamId]);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();
    }

    protected var _board :Board;
    protected var _sprite :Sprite;
    protected var _showingTeam :int = -1;

    protected static const TEAM_COLORS :Array = [ 0xFF0000, 0x0000FF ];
}

}
