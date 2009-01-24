package bloodbloom {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Heart extends SceneObject
{
    public function Heart ()
    {
        _sprite = new Sprite();

        var heart :Bitmap = ClientCtx.instantiateBitmap("heart");
        heart.x = -heart.width * 0.5;
        heart.y = -heart.height * 0.5;
        _sprite.addChild(heart);

        this.heartbeatTime = BASE_HEARTBEAT;
    }

    public function set heartbeatTime (val :Number) :void
    {
        removeAllTasks();
        addTask(new RepeatingTask(
            ScaleTask.CreateEaseIn(SCALE_BIG, SCALE_BIG, val * 0.5),
            ScaleTask.CreateEaseOut(SCALE_SMALL, SCALE_SMALL, val * 0.5)));
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;

    protected static const BASE_HEARTBEAT :Number = 1;
    protected static const SCALE_BIG :Number = 1.15;
    protected static const SCALE_SMALL :Number = 1;
}

}
