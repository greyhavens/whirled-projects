package {

import com.whirled.EntityControl;

public class QuestUtil
{
    public static function query (ctrl :EntityControl, filter :Function = null) :Array
    {
        var arr :Array = [];
        for each (var id :String in ctrl.getEntityIds()) {
            var svc :Object = ctrl.getEntityProperty(QuestConstants.SERVICE, id);
            if (svc != null && (filter == null || filter(id, svc))) {
                arr.push(svc);
            }
        }
        return arr;
    }

    public static function fetch (ctrl :EntityControl, angle :Number, range :Number) :Array
    {
        var range2 :Number = range*range;
        var me :Array = ctrl.getLogicalLocation();

        return query(ctrl, function (id :String, svc :Object) :Boolean {
            if (id == ctrl.getMyEntityId()) {
                return false;
            }
            var other :Array = ctrl.getEntityProperty(EntityControl.PROP_LOCATION_LOGICAL, id);
            var d2 :Number = (me[0]-other[0])*(me[0]-other[0]) + (me[2]-other[2])*(me[2]-other[2]);
            return d2 <= range2;
        });
    }

    public static function self (ctrl :EntityControl) :Object
    {
        return ctrl.getEntityProperty(QuestConstants.SERVICE);
    }
}

}
