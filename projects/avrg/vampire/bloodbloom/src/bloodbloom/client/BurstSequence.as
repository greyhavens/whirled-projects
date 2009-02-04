package bloodbloom.client {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.text.TextField;

public class BurstSequence extends SceneObject
{
    public function BurstSequence ()
    {
        _tf = UIBits.createText("");
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    public function addCellBurst (burst :CellBurst) :void
    {
        _bursts.push(burst.ref);
    }

    public function removeCellBurst (burst :CellBurst) :void
    {
        ArrayUtil.removeFirst(_bursts, burst.ref);
    }

    public function get cellCount () :int
    {
        return _bursts.length;
    }

    override protected function update (dt :Number) :void
    {
        var isSequenceAlive :Boolean = ArrayUtil.findIf(_bursts,
            function (burstRef :SimObjectRef) :Boolean {
                return !burstRef.isNull;
            });

        if (!isSequenceAlive) {
            var loc :Point = this.displayObject.parent.localToGlobal(new Point(this.x, this.y));
            ClientCtx.bloodMeter.addBlood(loc.x, loc.y, _bursts.length * _bursts.length);
            destroySelf();

        } else {
            if (_lastCellCount != _bursts.length) {
                var numBurstsString :String = String(_bursts.length);
                UIBits.initTextField(_tf, numBurstsString + "x" + numBurstsString, 2, 0, 0x0000ff);
                _lastCellCount = _bursts.length;
            }
        }
    }

    protected var _bursts :Array = [];
    protected var _lastCellCount :int;
    protected var _tf :TextField;
}

}
