package ghostbusters.client.fight.plasma {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObject;
import flash.display.Sprite;

import ghostbusters.client.fight.common.*;

public class Ectoplasm extends SceneObject
{
    public static const RADIUS :int = 10;
    public static const GROUP_NAME :String = "Ectoplasm";

    public function Ectoplasm (displayClass :Class)
    {
        _displayObj = new displayClass();

        var rotFrom :int = Rand.nextIntRange(-360, 360, Rand.STREAM_COSMETIC);
        var rotTo :int = (rotFrom > 0 ? rotFrom + 360 : rotFrom - 360);
        var rotTime :Number = Rand.nextNumberRange(2.5, 4.5, Rand.STREAM_COSMETIC);

        this.rotation = rotFrom;

        var swirlTask :RepeatingTask = new RepeatingTask();
        swirlTask.addTask(new RotationTask(rotTo, rotTime));
        swirlTask.addTask(new RotationTask(rotFrom));

        this.addTask(swirlTask);
    }

    override public function get displayObject () :DisplayObject
    {
        return _displayObj;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _displayObj :DisplayObject;

}

}
