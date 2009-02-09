package bloodbloom.client.view {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;

public class ClickIndicatorView extends SceneObject
{
    public function ClickIndicatorView ()
    {
        _shape = new Shape();
        var g :Graphics = _shape.graphics;
        g.lineStyle(1.5, 0xffffff);
        g.drawCircle(0, 0, 8);

        addTask(new AlphaTask(0, 0.5));
        addTask(new SerialTask(
            ScaleTask.CreateEaseIn(1.4, 1.4, 0.5),
            new SelfDestructTask()));
    }

    override public function get displayObject () :DisplayObject
    {
        return _shape;
    }

    protected var _shape :Shape;

}

}
