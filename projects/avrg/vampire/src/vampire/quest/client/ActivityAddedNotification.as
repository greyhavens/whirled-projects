package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.quest.*;

public class ActivityAddedNotification extends SceneObject
{
    public function ActivityAddedNotification (activity :ActivityDesc)
    {
        _movie = ClientCtx.instantiateMovieClip("quest", "popup_unlock_site");
        _movie.gotoAndPlay(1);

        var contents :MovieClip = _movie["contents"];
        var tfLocation :TextField = contents["location_name"];
        var tfActivity :TextField = contents["site_name"];

        tfLocation.text = activity.loc.displayName;
        tfActivity.text = activity.displayName;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;
}

}
