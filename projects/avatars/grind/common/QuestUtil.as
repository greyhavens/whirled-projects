package {

import com.whirled.EntityControl;

public class QuestUtil
{
    public static function query (ctrl :EntityControl, filter :Function = null) :Array
    {
        var arr :Array = [];
        for each (var id :String in ctrl.getEntityIds()) {
            var svc :Object = getService(ctrl, id);
            if (svc != null && (filter == null || filter(svc, id))) {
                arr.push(svc);
            }
        }
        return arr;
    }

    public static function getService (ctrl :EntityControl, otherId :String) :Object
    {
        return ctrl.getEntityProperty(QuestConstants.SERVICE_KEY, otherId);
    }

    public static function squareDistanceTo (ctrl :EntityControl, otherId :String) :Number
    {
        var me :Array = ctrl.getPixelLocation();
        var other :Array = ctrl.getEntityProperty(EntityControl.PROP_LOCATION_PIXEL, otherId) as Array;
        var d2 :Number = (me[0]-other[0])*(me[0]-other[0]) + (me[2]-other[2])*(me[2]-other[2]);
        return d2;
    }

    public static function fetchClosest (ctrl :EntityControl, filter :Function = null) :String
    {
        var min2 :Number = Number.MAX_VALUE;
        var candidate :String = null;
        var me :Array = ctrl.getPixelLocation();

        var arr :Array = [];
        for each (var id :String in ctrl.getEntityIds()) {
            if (id != ctrl.getMyEntityId()) {
                var svc :Object = getService(ctrl, id);
                if (svc != null && (filter == null || filter(svc, id))) {
                    var d2 :Number = squareDistanceTo(ctrl, id)
                    if (d2 < min2 && (filter == null || filter(svc, id))) {
                        min2 = d2;
                        candidate = id;
                    }
                }
            }
        }

        return candidate;
    }

    public static function fetchAll (ctrl :EntityControl, range :Number) :Array
    {
        var range2 :Number = range*range;
        var me :Array = ctrl.getPixelLocation();

        return query(ctrl, function (id :String, svc :Object) :Boolean {
            var other :Array = ctrl.getEntityProperty(EntityControl.PROP_LOCATION_PIXEL, id) as Array;
            var d2 :Number = (me[0]-other[0])*(me[0]-other[0]) + (me[2]-other[2])*(me[2]-other[2]);
            return d2 <= range2;
        });
    }

    public static function self (ctrl :EntityControl) :Object
    {
        return ctrl.getEntityProperty(QuestConstants.SERVICE_KEY);
    }

    public static function getTotem (ctrl :EntityControl) :int
    {
        for each (var id :String in ctrl.getEntityIds(EntityControl.TYPE_FURNI)) {
            var influence :int = int(ctrl.getEntityProperty(QuestConstants.TOTEM_KEY, id));
            if (influence != 0) {
                return Math.abs(influence);
            }
        }
        return 0;
    }
}

}
