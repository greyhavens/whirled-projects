package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

import mx.effects.easing.*;

import redrover.*;
import redrover.game.*;
import redrover.util.SpriteUtil;

public class GemsRedeemedAnim extends SceneObject
{
    public function GemsRedeemedAnim (player :Player, gems :Array, boardCell :BoardCell,
        earnedPoints :int)
    {
        _player = player;
        _gems = gems.slice();
        _numGems = gems.length;
        _cell = boardCell;
        _earnedPoints = earnedPoints;

        _sprite = SpriteUtil.createSprite();

        showNextAnim();
    }

    protected function showNextAnim () :void
    {
        if (_gems.length > 0) {
            showNextGemAnim();
        } else if (_player.playerIdx == ClientCtx.localPlayerIdx) {
            // only show the score animation for the local player
            showScoreAnim();
        } else {
            destroySelf();
        }
    }

    protected function showNextGemAnim () :void
    {
        removeDisplayChildren();

        var nextGemType :int = _gems.pop();
        var gemView :DisplayObject = GemViewFactory.createGem(20, nextGemType);
        gemView.x = -gemView.width * 0.5;
        gemView.y = -gemView.height * 0.5;
        _sprite.addChild(gemView);
        _sprite.x = _player.loc.x;
        _sprite.y = _player.loc.y - 40;
        var targetX0 :int = _sprite.x + ((_cell.ctrPixelX - _sprite.x) * 0.5);
        var targetY0 :int = Math.min(_sprite.y, _cell.ctrPixelY) - 40;
        var targetX1 :int = _cell.ctrPixelX;
        var targetY1 :int = _cell.ctrPixelY;
        addTask(new SerialTask(
            new ComplexLocationTask(targetX0, targetY0, 0.2, Linear.easeNone, Circular.easeOut),
            new ComplexLocationTask(targetX1, targetY1, 0.2, Linear.easeNone, Circular.easeIn),
            new FunctionTask(showNextAnim)));
    }

    protected function showScoreAnim () :void
    {
        var text :String = "You redeemed " + _numGems + " gems.\n" +
            "The " + Constants.TEAM_LEADER_NAMES[_player.teamId] + " is " +
            HAPPINESS[_numGems < HAPPINESS.length ? _numGems : HAPPINESS.length - 1] +
            " (" + (_earnedPoints >= 0 ? "+" : "") + _earnedPoints + ")";

        GameCtx.notificationMgr.showNotification(
            _player,
            text,
            new Point(0, -100),
            NotificationMgr.MAJOR,
            "sfx_got_points");

        destroySelf();
    }

    protected function removeDisplayChildren () :void
    {
        while (_sprite.numChildren > 0) {
            _sprite.removeChildAt(_sprite.numChildren - 1);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (!_player.isOnOwnBoard) {
            destroySelf();
        }
    }

    protected var _player :Player;
    protected var _gems :Array;
    protected var _cell :BoardCell;
    protected var _earnedPoints :int;
    protected var _numGems :int;

    protected var _sprite :Sprite;

    protected static const HAPPINESS :Array = [
        "", "pleased.", "pleased.", "pleased.", "very happy.", "delighted!",
        "jubilant!", "overjoyed!", "elated!", "ECSTATIC!", "EUPHORIC!",
    ];
}

}
