package simon {

import com.whirled.AVRGameAvatar;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.text.TextField;

public class WinnerCloudController extends SceneObject
{
    public static const NAME :String = "WinnerCloudController";

    public function WinnerCloudController (playerId :int)
    {
        _playerId = playerId;

        _movieClip = Resources.instantiateMovieClip("ui", "win_cloud");

        var loc :Point = this.screenLoc;

        _movieClip.x = loc.x;
        _movieClip.y = loc.y;

        var playerText :TextField = _movieClip["winner"];
        // @TODO - uncomment when win_cloud is fixed
        //playerText.text = SimonMain.getPlayerName(playerId);
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movieClip;
    }

    public function get screenLoc () :Point
    {
        var p :Point;

        var avatarInfo :AVRGameAvatar = (SimonMain.control.isConnected() ? SimonMain.control.getAvatarInfo(_playerId) : null);
        if (null != avatarInfo) {
            p = SimonMain.control.locationToStage(avatarInfo.x, avatarInfo.y, avatarInfo.z);
            p.y -= avatarInfo.stageBounds.height;
        }

        return (null != p ? p : new Point(150, 300));
    }

    protected var _movieClip :MovieClip;
    protected var _playerId :int;

}

}
