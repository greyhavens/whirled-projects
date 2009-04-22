package vampire.client
{
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.tasks.AlphaTask;
    import com.whirled.contrib.simplegame.tasks.FunctionTask;
    import com.whirled.contrib.simplegame.tasks.SelfDestructTask;
    import com.whirled.contrib.simplegame.tasks.SerialTask;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.filters.GlowFilter;

public class ClientUtil
{
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
        serialTask.addTask(AlphaTask.CreateEaseIn(0, ANIMATION_TIME));
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
        sceneButton.alpha = 0;
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



    public static const ANIMATION_TIME :Number = 0.2;
    public static const glowFilter :GlowFilter = new GlowFilter(0xffffff);
}
}