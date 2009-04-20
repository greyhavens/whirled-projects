package vampire.feeding.client {

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

    override protected function addedToDB () :void
    {
        GameCtx.tipFactory.createTip(TipFactory.CASCADE, this, false);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function addCellBurst (burst :CellBurst) :void
    {
        if (_type < 0) {
            _type = (burst is CorruptionBurst ? TYPE_CORRUPTION : TYPE_NORMAL);
        }

        _bursts.push(burst.ref);
        _totalBursts++;
        if (Constants.MULTIPLIERS_ADD && burst.multiplier > 1) {
            _totalMultiplier =
                (_totalMultiplier == 1 ? burst.multiplier : _totalMultiplier + burst.multiplier);
        } else if (!Constants.MULTIPLIERS_ADD) {
            _totalMultiplier *= burst.multiplier;
        }

        _largestMultiplier = Math.max(_largestMultiplier, burst.multiplier);

        _lastBurstX = burst.x;
        _lastBurstY = burst.y;
        _needsRelocate = true;
    }

    public function removeCellBurst (burst :CellBurst) :void
    {
        ArrayUtil.removeFirst(_bursts, burst.ref);
        _totalBursts--;
        if (Constants.MULTIPLIERS_ADD && burst.multiplier > 1) {
            _totalMultiplier = Math.max(_totalMultiplier - burst.multiplier, 1);
        } else {
            _totalMultiplier /= burst.multiplier;
        }
    }

    public function get cellCount () :int
    {
        return _bursts.length;
    }

    public function get totalValue () :int
    {
        return _totalBursts * this.multiplier;
    }

    public function get multiplier () :int
    {
        return Math.min(_totalMultiplier, Constants.MAX_MULTIPLIER);
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
        var isSequenceAlive :Boolean = !GameCtx.gameOver && ArrayUtil.findIf(_bursts,
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
                if (this.multiplier > 1) {
                    text += " x" + this.multiplier;
                }

                if (_needsRelocate) {
                    addNamedTask(
                        "Relocate",
                        LocationTask.CreateSmooth(_lastBurstX, _lastBurstY, 0.5),
                        true);
                }
            }

            if (this.hasScoreValue) {
                TextBits.initTextField(_tf, text, 2, 0, 0xD8F1FC);
                _tf.x = -_tf.width * 0.5;
                _tf.y = -_tf.height * 0.5;

                _lastCellCount = _bursts.length;
            }
        }
    }

    protected function deliverPayload () :void
    {
        if (this.totalValue > 0 && this.hasScoreValue) {
            var loc :Point = this.displayObject.parent.localToGlobal(new Point(this.x, this.y));
            GameCtx.score.addBlood(loc.x, loc.y, this.totalValue, 0);
        }

        if (_totalBursts >= Constants.CREATE_BONUS_BURST_SIZE && this.createMultiplier) {
            // Send a multiplier to the other players
            var multiplierSize :int = Math.min(this.multiplier + 1, Constants.MAX_MULTIPLIER);
            GameCtx.gameMode.sendMultiplier(multiplierSize, this.x, this.y);

            // Show an animation of this happening
            GameCtx.sentMultiplierIndicator.showAnim(multiplierSize, this.x, this.y);
        }

        // trophies
        if (_type == TYPE_NORMAL) {
            ClientCtx.awardTrophySequence(
                Trophies.CASCADE_TROPHIES,
                Trophies.CASCADE_REQS,
                this.totalValue);

            ClientCtx.awardTrophySequence(
                Trophies.MULTIPLIER_TROPHIES,
                Trophies.MULTIPLIER_REQS,
                this.multiplier);
        }
    }

    protected function get createMultiplier () :Boolean
    {
        return this.hasScoreValue;
    }

    protected function get hasScoreValue () :Boolean
    {
        return (ClientCtx.variantSettings.scoreCorruption && _type == TYPE_CORRUPTION) ||
               (!ClientCtx.variantSettings.scoreCorruption && _type != TYPE_CORRUPTION);
    }

    protected var _type :int = -1;
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

    protected static const TYPE_NORMAL :int = 0;
    protected static const TYPE_CORRUPTION :int = 1;
}

}
