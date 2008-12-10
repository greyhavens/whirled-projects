package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import redrover.game.*;
import redrover.ui.UIBits;
import redrover.util.SpriteUtil;

public class SwitchBoardsButton extends SceneObject
{
    public function SwitchBoardsButton ()
    {
        _sprite = SpriteUtil.createSprite(true);

        _ownBoardStates = [
            UIBits.createButton("Break on Through!", 1.5),
            null,
            UIBits.createTextPanel("Break on Through!", 1.5, 0, 0x888888)
        ];

        _otherBoardStates = [
            UIBits.createButton("Return Home!", 1.5),
            UIBits.createTextPanel(
                "" + GameContext.levelData.returnHomeGemsMin +  " gems are required" +
                " to return home.", 1.2, 0, 0x888888),
            UIBits.createTextPanel("Return Home!", 1.5, 0, 0x888888)
        ];

        registerListener(_ownBoardStates[ACTIVE], MouseEvent.CLICK, onClicked);
        registerListener(_otherBoardStates[ACTIVE], MouseEvent.CLICK, onClicked);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function onClicked (...ignored) :void
    {
        if (GameContext.localPlayer.canSwitchBoards) {
            GameContext.localPlayer.beginSwitchBoards();
        }
    }

    override protected function update (dt :Number) :void
    {
        // discover which state we should be in
        var player :Player = GameContext.localPlayer;
        var buttonStates :Array = (player.isOnOwnBoard ? _ownBoardStates : _otherBoardStates);
        var curState :DisplayObject;
        if (player.state == Player.STATE_SWITCHINGBOARDS) {
            curState = buttonStates[SWITCHING];
        } else {
            curState = buttonStates[player.canSwitchBoards ? ACTIVE : INACTIVE];
        }

        setDisplayState(curState);
    }

    protected function setDisplayState (newState :DisplayObject) :void
    {
        if (newState != _curState) {
            if (_curState != null) {
                _curState.parent.removeChild(_curState);
            }

            _curState = newState;
            _curState.x = -_curState.width;
            _curState.y = -_curState.height * 0.5;
            _sprite.addChild(_curState);
        }
    }

    protected var _sprite :Sprite;

    protected var _curState :DisplayObject;
    protected var _ownBoardStates :Array;
    protected var _otherBoardStates :Array;

    protected static const ACTIVE :int = 0;
    protected static const INACTIVE :int = 1;
    protected static const SWITCHING :int = 2;
}

}
