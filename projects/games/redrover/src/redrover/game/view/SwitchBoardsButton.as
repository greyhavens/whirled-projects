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
        _activeState = UIBits.createButton("Break on Through!", 1.5);
        _needGemsState = UIBits.createTextPanel(
            "" + GameContext.levelData.returnHomeGemsMin +  " gems are required\n" +
            "to return home.", 1.2, 0, 0x888888);
        _switchingState = UIBits.createTextPanel("Break on Through!", 1.5, 0, 0x888888);

        registerListener(_activeState, MouseEvent.CLICK, onClicked);
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
        var curButton :DisplayObject;
        var player :Player = GameContext.localPlayer;
        if (player.state == Player.STATE_SWITCHINGBOARDS) {
            curButton = _switchingState;
        } else if (!player.isOnOwnBoard && player.numGems < GameContext.levelData.returnHomeGemsMin) {
            curButton = _needGemsState;
        } else {
            curButton = _activeState;
        }

        setDisplayState(curButton);
    }

    protected function setDisplayState (newState :DisplayObject) :void
    {
        if (newState != _curState) {
            if (_curState != null) {
                _curState.parent.removeChild(_curState);
            }

            _curState = newState;
            _curState.x = -_curState.width * 0.5;
            _curState.y = -_curState.height * 0.5;
            _sprite.addChild(_curState);
        }
    }

    protected var _sprite :Sprite;

    protected var _curState :DisplayObject;
    protected var _activeState :SimpleButton;
    protected var _needGemsState :DisplayObject;
    protected var _switchingState :DisplayObject;
}

}
