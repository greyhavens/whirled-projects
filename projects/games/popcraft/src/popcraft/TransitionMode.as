package popcraft {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

public class TransitionMode extends AppMode
{
    public function TransitionMode ()
    {
        this.modeSprite.addChild(_modeLayer);
        this.modeSprite.addChild(_fadeLayer);
    }

    protected function fadeIn (callback :Function = null, time :Number = DEFAULT_FADE_TIME) :void
    {
        var darkness :SceneObject = this.darkness;

        darkness.removeAllTasks();
        darkness.alpha = 1;
        darkness.visible = true;

        var fadeTask :SerialTask = new SerialTask();
        fadeTask.addTask(new AlphaTask(0, time));
        fadeTask.addTask(new VisibleTask(false));
        if (null != callback) {
            fadeTask.addTask(new FunctionTask(callback));
        }

        darkness.addTask(fadeTask);
    }

    protected function fadeOut (callback :Function = null, time :Number = DEFAULT_FADE_TIME) :void
    {
        var darkness :SceneObject = this.darkness;

        darkness.removeAllTasks();
        darkness.alpha = 0;
        darkness.visible = true;

         var fadeTask :SerialTask = new SerialTask();
        fadeTask.addTask(new AlphaTask(1, time));
        if (null != callback) {
            fadeTask.addTask(new FunctionTask(callback));
        }

        darkness.addTask(fadeTask);
    }

    protected function fadeOutToMode (nextMode :AppMode, time :Number = DEFAULT_FADE_TIME) :void
    {
        fadeOut(function () :void { ClientCtx.mainLoop.unwindToMode(nextMode); }, time);
    }

    protected function get darkness () :SceneObject
    {
        if (null == _darkness) {
            var shape :Shape = new Shape();
            var g :Graphics = shape.graphics;
            g.beginFill(0);
            g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
            g.endFill();

            _darkness = new SimpleSceneObject(shape);
            addObject(_darkness, _fadeLayer);
        }

        return _darkness;
    }

    protected var _modeLayer :Sprite = new Sprite();
    protected var _fadeLayer :Sprite = new Sprite();
    protected var _darkness :SimpleSceneObject;

    protected static const DEFAULT_FADE_TIME :Number = 1;
}

}
