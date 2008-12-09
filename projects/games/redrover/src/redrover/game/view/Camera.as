package redrover.game.view {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.ScaleTask;

import flash.display.DisplayObject;
import flash.display.Sprite;

import redrover.*;
import redrover.data.LevelData;
import redrover.game.*;
import redrover.util.SpriteUtil;

public class Camera extends SceneObject
{
    public function Camera (width :Number, height :Number)
    {
        _width = width;
        _height = height;
        _sprite = SpriteUtil.createSprite(true);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var data :LevelData = GameContext.levelData;

        // When the local player switches boards, update the camera
        var newBoardId :int = GameContext.localPlayer.curBoardId;
        if (_lastBoardId != newBoardId) {
            if (_curTeamSprite != null) {
                _sprite.removeChild(_curTeamSprite);
            }

            var newTeamSprite :TeamSprite = GameContext.gameMode.getTeamSprite(newBoardId);
            _sprite.addChild(newTeamSprite);

            _lastBoardId = newBoardId;
            _curTeamSprite = newTeamSprite;
        }

        var isOnOwnBoard :Boolean = GameContext.localPlayer.isOnOwnBoard;
        if (_wasOnOwnBoard != isOnOwnBoard) {
            var targetScale :Number = (isOnOwnBoard ? data.ownBoardZoom : data.otherBoardZoom);
            addNamedTask(ZOOM_TASK_NAME,
                         ScaleTask.CreateSmooth(targetScale, targetScale, ZOOM_TIME),
                         true);

             _wasOnOwnBoard = isOnOwnBoard;
        }

        // Keep the player centered in the view as much as possible
        var playerLoc :Vector2 = GameContext.localPlayer.loc;
        var scale :Number = _sprite.scaleX;
        var board :Board = GameContext.gameMode.getBoard(_lastBoardId);

        var camX :Number = (-_width * 0.5 / scale) + (playerLoc.x);
        var camY :Number = (-_height * 0.5 / scale) + (playerLoc.y);

        camX = Math.min(camX, board.pixelWidth - (_width / scale));
        camX = Math.max(camX, 0);
        camY = Math.min(camY, board.pixelHeight - (_height / scale));
        camY = Math.max(camY, 0);

        _curTeamSprite.x = -camX;
        _curTeamSprite.y = -camY;
    }

    protected var _width :Number;
    protected var _height :Number;
    protected var _sprite :Sprite;
    protected var _lastBoardId :int = -1;
    protected var _wasOnOwnBoard :Boolean;
    protected var _curTeamSprite :TeamSprite;

    protected static const ZOOM_TIME :Number = 0.75;
    protected static const ZOOM_TASK_NAME :String = "Zoom";
}

}
