package simon {

import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class HelpViewController extends SceneObject
{
    public function HelpViewController ()
    {
        _movieClip = SwfResource.instantiateMovieClip("ui", "help_cloud");
    }

    override protected function addedToDB () :void
    {
        var closeButton :InteractiveObject = _movieClip["close"];
        closeButton.addEventListener(MouseEvent.CLICK, closeClicked, false, 0, true);

        SimonMain.control.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged, false, 0, true);

        this.handleSizeChanged();
    }

    override protected function removedFromDB () :void
    {
        var closeButton :InteractiveObject = _movieClip["close"];
        closeButton.removeEventListener(MouseEvent.CLICK, closeClicked);

        SimonMain.control.local.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movieClip;
    }

    protected function closeClicked (...ignored) :void
    {
        (this.db as GameMode).helpScreenVisible = false;
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var loc :Point = this.properLocation;

        _movieClip.x = loc.x;
        _movieClip.y = loc.y;
    }

    protected function get properLocation () :Point
    {
        var loc :Point;

        if (SimonMain.control.isConnected()) {
            var stageSize :Rectangle = SimonMain.control.local.getPaintableArea(true);

            loc = (null != stageSize
                    ? new Point(stageSize.right + SCREEN_EDGE_OFFSET.x, stageSize.top + SCREEN_EDGE_OFFSET.y)
                    : new Point(0, 0));

        } else {
            loc = new Point(700 + SCREEN_EDGE_OFFSET.x, SCREEN_EDGE_OFFSET.y);
        }

        return loc;
    }

    protected var _movieClip :MovieClip;

    protected static const SCREEN_EDGE_OFFSET :Point = new Point(-220, -20);
}

}
