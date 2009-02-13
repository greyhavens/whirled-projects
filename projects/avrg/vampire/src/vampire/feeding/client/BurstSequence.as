package vampire.feeding.client {

import vampire.feeding.*;
import vampire.feeding.client.view.*;
import vampire.feeding.net.CreateBonusMsg;

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.text.TextField;

public class BurstSequence extends SceneObject
{
    public static function get sequenceExists () :Boolean
    {
        return (GameCtx.gameMode.getObjectRefsInGroup(GROUP_NAME).length > 0);
    }

    public function BurstSequence ()
    {
        _tf = UIBits.createText("");
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    public function addCellBurst (burst :RedBurst) :void
    {
        _bursts.push(burst.ref);
        _totalBursts++;
        _totalMultiplier *= burst.multiplier;
        _largestMultiplier = Math.max(_largestMultiplier, burst.multiplier);
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
            if (this.totalValue > 0) {
                var loc :Point = this.displayObject.parent.localToGlobal(new Point(this.x, this.y));
                GameCtx.bloodMeter.addBlood(loc.x, loc.y, this.totalValue);
            }

            if (_totalBursts >= Constants.CREATE_BONUS_BURST_SIZE) {
                ClientCtx.msgMgr.sendMessage(CreateBonusMsg.create(
                    ClientCtx.localPlayerId,
                    this.x,
                    this.y,
                    _largestMultiplier + 1));
            }

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
            }

            UIBits.initTextField(_tf, text, 2, 0, 0x0000ff);
            _lastCellCount = _bursts.length;
        }
    }

    protected var _bursts :Array = [];
    protected var _largestMultiplier :int;
    protected var _totalMultiplier :int = 1;
    protected var _totalBursts :int;
    protected var _lastCellCount :int;
    protected var _tf :TextField;

    protected static const GROUP_NAME :String = "BurstSequence";
}

}
