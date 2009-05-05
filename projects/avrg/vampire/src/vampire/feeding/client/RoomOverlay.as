package vampire.feeding.client {

import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.AlphaTask;
import com.whirled.contrib.simplegame.tasks.SelfDestructTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Rectangle;

public class RoomOverlay extends SceneObject
{
    public static function get exists () :Boolean
    {
        return (GameCtx.gameMode.getObjectNamed("RoomOverlay") != null);
    }

    public function RoomOverlay ()
    {
        _shape = new Shape();
        updateShape();

        if (ClientCtx.isConnected) {
            registerListener(
                ClientCtx.gameCtrl.local,
                AVRGameControlEvent.SIZE_CHANGED,
                updateShape);
        }

        // fade in
        this.alpha = 0;
        addTask(new AlphaTask(1, 1));
    }

    protected function updateShape (...ignored) :void
    {
        var bounds :Rectangle = (ClientCtx.isConnected ?
            ClientCtx.gameCtrl.local.getPaintableArea(false) :
            new Rectangle(0, 0, 1000, 500));

        var g :Graphics = _shape.graphics;
        g.clear();
        g.beginFill(ClientCtx.variantSettings.scoreCorruption ? CORRUPTION_COLOR : NORMAL_COLOR);
        g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
        g.endFill();
    }

    override protected function update (dt :Number) :void
    {
        if (GameCtx.gameOver && !_dying) {
            removeAllTasks();
            addTask(new SerialTask(new AlphaTask(0, 1), new SelfDestructTask()));
            _dying = true;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _shape;
    }

    override public function get objectName () :String
    {
        return "RoomOverlay";
    }

    protected var _shape :Shape;
    protected var _dying :Boolean;

    protected static const NORMAL_COLOR :uint = 0x110000;
    protected static const CORRUPTION_COLOR :uint = 0x162c36
}

}
