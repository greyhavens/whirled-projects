package vampire.combat.client
{
import com.whirled.contrib.simplegame.objects.DraggableObject;

import flash.display.DisplayObject;

public class SimpleDraggableObject extends DraggableObject
{
    public function SimpleDraggableObject(d :DisplayObject)
    {
        _displayObject = d;
        super();
    }

    override public function get displayObject () :DisplayObject
    {
        return _displayObject;
    }

    protected var _displayObject :DisplayObject;
}
}