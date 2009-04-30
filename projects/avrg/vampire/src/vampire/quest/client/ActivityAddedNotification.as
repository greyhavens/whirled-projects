package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.feeding.client.SpriteUtil;
import vampire.quest.*;

public class ActivityAddedNotification extends SceneObject
{
    public function ActivityAddedNotification (activity :ActivityDesc)
    {
        _activity = activity;
        _sprite = SpriteUtil.createSprite();
    }

    override protected function addedToDB () :void
    {
        var movie :MovieClip = ClientCtx.instantiateMovieClip("quest", "popup_sitequest");

        var contents :MovieClip = movie["contents"];
        var tfLocation :TextField = contents["context_name"];
        var tfActivity :TextField = contents["item_name"];

        tfLocation.text = _activity.loc.displayName;
        tfActivity.text = _activity.displayName;

        _sprite.addChild(movie);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _activity :ActivityDesc
}

}
