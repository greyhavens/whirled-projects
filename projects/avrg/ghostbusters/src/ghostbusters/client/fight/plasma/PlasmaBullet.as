package ghostbusters.client.fight.plasma {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;

import ghostbusters.client.fight.common.*;

public class PlasmaBullet extends SceneObject
{
    public static const RADIUS :Number = 6;
    public static const GROUP_NAME :String = "PlasmaBullet";

    public function PlasmaBullet (displayClass :Class)
    {
        _displayObject = new displayClass();
    }

    override public function get displayObject () :DisplayObject
    {
        return _displayObject;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _displayObject :DisplayObject;
}

}
