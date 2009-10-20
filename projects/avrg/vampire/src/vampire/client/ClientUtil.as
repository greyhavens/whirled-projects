package vampire.client {

import com.threerings.flashbang.objects.SceneObject;
import com.threerings.flashbang.tasks.AlphaTask;
import com.threerings.flashbang.tasks.FunctionTask;
import com.threerings.flashbang.tasks.SelfDestructTask;
import com.threerings.flashbang.tasks.SerialTask;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.SimpleButton;
import flash.filters.GlowFilter;
import flash.text.TextField;

public class ClientUtil
{
    public static const ANIMATION_TIME :Number = 0.2;
    public static const GLOW_FILTER :GlowFilter = new GlowFilter(0xffffff);

    public static function detach (d :DisplayObject) :void
    {
        if (d != null && d.parent != null) {
            d.parent.removeChild(d);
        }
    }

    public static function fadeOutAndDetachSceneObject (sceneButton :SceneObject,
        destroyAfter :Boolean = false) :void
    {
        if(sceneButton == null || sceneButton.displayObject == null ||
            sceneButton.displayObject.parent == null) {
            return;
        }

        var serialTask :SerialTask = new SerialTask();
//        serialTask.addTask(AlphaTask.CreateEaseIn(0, ANIMATION_TIME));
        serialTask.addTask(new FunctionTask(function() :void {
            detach(sceneButton.displayObject);
        }));

        if (destroyAfter) {
            serialTask.addTask(new SelfDestructTask());
        }

        sceneButton.addTask(serialTask);
    }

    public static function fadeInSceneObject (sceneButton :SceneObject,
        parent :DisplayObjectContainer = null) :void
    {
//        sceneButton.alpha = 0;
        if (parent != null) {
            parent.addChild(sceneButton.displayObject);
        }
        sceneButton.addTask(AlphaTask.CreateEaseIn(1, ANIMATION_TIME));
    }

    public static function traceDisplayChildren (d :DisplayObjectContainer) :void
    {
        for (var ii :int = 0; ii < d.numChildren; ++ii) {
            trace("Child " + ii + "=" + d.getChildAt(ii).name);
        }
    }

    public static function setButtonText (button :SimpleButton, text :String) :void
    {
        // Holy shit, this is an ugly hack. Flash doesn't allow access to named
        // instances inside SimpleButtons, because they aren't DisplayObjectContainers.
        // So we iterate the children of the each of the button's display states until we
        // find a TextField, and use that. This might fail if there are multiple TextFields.
        var setText :Function = function (disp :DisplayObjectContainer) :void {
            for (var ii :int = 0; ii < disp.numChildren; ++ii) {
                var child :DisplayObject = disp.getChildAt(ii);
                if (child is TextField) {
                    (child as TextField).text = text;
                    return;
                }
            }
        }

        setText(button.upState);
        setText(button.downState);
        setText(button.overState);
        setText(button.hitTestState);
    }
}
}
