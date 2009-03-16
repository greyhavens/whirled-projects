package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import vampire.feeding.*;
import vampire.server.Trophies;

public class BurstSequence extends SceneObject
{
    public static function get sequenceExists () :Boolean
    {
        return (GameCtx.gameMode.getObjectRefsInGroup(GROUP_NAME).length > 0);
    }

    public function BurstSequence ()
    {
        _tf = TextBits.createText("");
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_tf);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function addCellBurst (burst :RedBurst) :void
    {
        _bursts.push(burst.ref);
        _totalBursts++;
        _totalMultiplier *= burst.multiplier;
        _largestMultiplier = Math.max(_largestMultiplier, burst.multiplier);

        _lastBurstX = burst.x;
        _lastBurstY = burst.y;
        _needsRelocate = true;
    }

    public function removeCellBurst (burst :RedBurst) :void
    {
        ArrayUtil.removeFirst(_bursts, burst.ref);
        _totalBursts--;
        _totalMultiplier /= burst.multiplier;
    }

    public function get cellCount () :int
    {
        return _bursts.length;
    }

    public function get totalValue () :int
    {
        return _totalBursts * _totalMultiplier;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return GROUP_NAME;
        default:    return super.getObjectGroup(groupNum - 1);
        }
    }

    override protected function update (dt :Number) :void
    {
        var isSequenceAlive :Boolean = ArrayUtil.findIf(_bursts,
            function (burstRef :SimObjectRef) :Boolean {
                return !burstRef.isNull;
            });

        if (!isSequenceAlive) {
            deliverPayload();
            destroySelf();

        } else if (_lastCellCount != _bursts.length) {
            var text :String;
            if (_bursts.length == 0) {
                text = "";
            } else {
                text = String(_totalBursts);
                if (_totalMultiplier > 1) {
                    text += " x" + _totalMultiplier;
                }

                if (_needsRelocate) {
                    addNamedTask(
                        "Relocate",
                        LocationTask.CreateSmooth(_lastBurstX, _lastBurstY, 0.5),
                        true);
                }
            }

            TextBits.initTextField(_tf, text, 2, 0, 0xD8F1FC);
            _tf.x = -_tf.width * 0.5;
            _tf.y = -_tf.height * 0.5;

            _lastCellCount = _bursts.length;
        }
    }

    protected function deliverPayload () :void
    {
        if (this.totalValue > 0) {
            var loc :Point = this.displayObject.parent.localToGlobal(new Point(this.x, this.y));
            GameCtx.scoreView.addBlood(loc.x, loc.y, this.totalValue, 0);
        }

        if (_totalBursts >= Constants.CREATE_BONUS_BURST_SIZE) {
            // Send a multiplier to the other players
            var multiplierSize :int = _totalMultiplier + 1;
            GameCtx.gameMode.sendMultiplier(multiplierSize, this.x, this.y);

            // Show an animation of this happening
            var anim :NewBonusAnimation = new NewBonusAnimation(
                NewBonusAnimation.TYPE_SEND,
                multiplierSize,
                new Vector2(this.x, this.y));
            GameCtx.gameMode.addSceneObject(anim, GameCtx.uiLayer);
        }

        // trophies
        ClientCtx.awardTrophySequence(
            Trophies.CASCADE_TROPHIES,
            Trophies.CASCADE_REQS,
            _totalBursts);

        ClientCtx.awardTrophySequence(
            Trophies.MULTIPLIER_TROPHIES,
            Trophies.MULTIPLIER_REQS,
            _totalMultiplier);
    }

    protected var _bursts :Array = [];
    protected var _largestMultiplier :int;
    protected var _totalMultiplier :int = 1;
    protected var _totalBursts :int;
    protected var _lastCellCount :int;
    protected var _lastBurstX :Number = 0;
    protected var _lastBurstY :Number = 0;
    protected var _needsRelocate :Boolean;

    protected var _sprite :Sprite;
    protected var _tf :TextField;

    protected static const GROUP_NAME :String = "BurstSequence";
}

}
