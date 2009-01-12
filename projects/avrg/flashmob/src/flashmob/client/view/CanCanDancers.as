package flashmob.client.view {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import flashmob.client.*;

public class CanCanDancers extends SceneObject
{
    public function CanCanDancers ()
    {
        _movie = SwfResource.instantiateMovieClip("can_can", "multiplecancans", true, true);
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;
}

}
