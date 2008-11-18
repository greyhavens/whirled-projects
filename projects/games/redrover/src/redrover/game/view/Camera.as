package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;

import redrover.*;
import redrover.game.*;
import redrover.util.SpriteUtil;

public class Camera extends SceneObject
{
    public function Camera ()
    {
        _sprite = SpriteUtil.createSprite(true);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var showTeamId :int = GameContext.localPlayer.curBoardTeamId;
        if (_showingTeamId != showTeamId) {
            if (_sprite.numChildren > 0) {
                _sprite.removeChildAt(0);
            }

            _sprite.addChild(GameContext.gameMode.getTeamSprite(showTeamId));
            _showingTeamId = showTeamId;
        }
    }

    protected var _sprite :Sprite;
    protected var _showingTeamId :int = -1;
}

}
