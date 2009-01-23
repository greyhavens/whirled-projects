package flashmob.client.view {

import com.threerings.util.ArrayUtil;

import flash.display.DisplayObject;
import flash.geom.Point;

import flashmob.client.ClientCtx;

public class HitTester
{
    public function setup () :void
    {
        _oldHitTester = ClientCtx.gameCtrl.local.hitPointTester;
        ClientCtx.gameCtrl.local.setHitPointTester(hitTest);
    }

    public function shutdown () :void
    {
        ClientCtx.gameCtrl.local.setHitPointTester(_oldHitTester);
        _oldHitTester = null;
    }

    public function addExcludedObj (obj :DisplayObject) :void
    {
        _excludedObjs.push(obj);
    }

    public function removeExcludedObj (obj :DisplayObject) :void
    {
        ArrayUtil.removeFirst(_excludedObjs, obj);
    }

    protected function hitTest (x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        for each (var obj :DisplayObject in _excludedObjs) {
            if (obj.hitTestPoint(x, y, shapeFlag)) {
                return false;
            }
        }

        return _oldHitTester(x, y, shapeFlag);
    }

    protected var _oldHitTester :Function;
    protected var _excludedObjs :Array = [];

}

}
