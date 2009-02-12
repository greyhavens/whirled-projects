package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;
import bloodbloom.net.CreateBonusMsg;

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
        _bonusMultiplier += burst.multiplier;
    }

    public function removeCellBurst (burst :RedBurst) :void
    {
        ArrayUtil.removeFirst(_bursts, burst.ref);
        _totalBursts--;
        _bonusMultiplier -= burst.multiplier;
    }

    public function get cellCount () :int
    {
        return _bursts.length;
    }

    public function get multiplier () :int
    {
        //return 1 + (_totalBursts / Constants.NUM_BURSTS_PER_MULTIPLIER);
        return 1 + _bonusMultiplier;
    }

    public function get totalValue () :int
    {
        //return _bursts.length * this.multiplier;
        return _totalBursts * this.multiplier;
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
                ClientCtx.sendMessage(
                    CreateBonusMsg.create(this.x, this.y, 1, ClientCtx.localPlayerId));
            }

            destroySelf();

        } else if (_lastCellCount != _bursts.length) {
            var text :String;
            if (_bursts.length == 0) {
                text = "";
            } else {
                //text = String(_bursts.length);
                text = String(_totalBursts);
                if (this.multiplier > 1) {
                    text += " x" + this.multiplier;
                }
            }

            UIBits.initTextField(_tf, text, 2, 0, 0x0000ff);
            _lastCellCount = _bursts.length;
        }
    }

    protected var _bursts :Array = [];
    protected var _bonusMultiplier :int;
    protected var _totalBursts :int;
    protected var _lastCellCount :int;
    protected var _tf :TextField;

    protected static const GROUP_NAME :String = "BurstSequence";
}

}
