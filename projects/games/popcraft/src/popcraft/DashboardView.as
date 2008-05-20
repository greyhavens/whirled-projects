package popcraft {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;

public class DashboardView extends SceneObject
{
    public function DashboardView ()
    {
        _movie = SwfResource.instantiateMovieClip("dashboard", "dashboard_sym");
    }

    public function get puzzleFrame () :MovieClip
    {
        return _movie["frame_puzzle"];
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;

}

}
