package simon.tasks {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.MovieClip;

public class WaitForFrameTask implements ObjectTask
{
    public function WaitForFrameTask (frameName :String)
    {
        _frameName = frameName;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var sc :SceneComponent = obj as SceneComponent;
        var movieClip :MovieClip = (null != sc ? sc.displayObject as MovieClip : null);

        if (null == movieClip) {
            throw new Error("WaitForFrameTask can only operate on SceneComponents with MovieClip DisplayObjects");
        }

        return (movieClip.currentLabel == _frameName);
    }

    public function clone () :ObjectTask
    {
        return new WaitForFrameTask(_frameName);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _frameName :String;

}

}
