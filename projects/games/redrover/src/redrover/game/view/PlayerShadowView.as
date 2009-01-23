package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import redrover.*;
import redrover.game.*;
import redrover.util.SpriteUtil;

public class PlayerShadowView extends SceneObject
{
    public function PlayerShadowView (player :Player)
    {
        _player = player;

        var shadow :Bitmap = ImageResource.instantiateBitmap(AppContext.rsrcs, "player_shadow");
        var targetSize :Number = GameContext.levelData.cellSize * 0.8;
        var scale :Number = Math.min(targetSize / shadow.width, targetSize / shadow.height);
        shadow.scaleX = scale;
        shadow.scaleY = scale;
        shadow.x = -shadow.width * 0.5;
        shadow.y = -shadow.height * 0.5;
        shadow.alpha = 0.8;

        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(shadow);
    }

    override protected function update (dt :Number) :void
    {
        if (!_player.isLiveObject) {
            destroySelf();
            return;
        }

        super.update(dt);

        // only show enemy team shadows
        if (_player.teamId == GameContext.localPlayer.teamId) {
            this.visible = false;

        } else {
            this.visible = true;

            var curBoardId :int = _player.curBoardId;
            if (curBoardId != _lastBoardId) {
                var teamSprite :TeamSprite =
                    GameContext.gameMode.getTeamSprite(Constants.getOtherTeam(curBoardId));
                teamSprite.shadowLayer.addChild(_sprite);
                _lastBoardId = curBoardId;
            }

            this.x = _player.loc.x;
            this.y = _player.loc.y;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _player :Player;
    protected var _sprite :Sprite;
    protected var _lastBoardId :int = -1;
}

}
