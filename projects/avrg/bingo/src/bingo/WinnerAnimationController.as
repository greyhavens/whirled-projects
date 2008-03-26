package bingo {

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.AVRGameControlEvent;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.text.TextField;
import flash.geom.Point;
import flash.geom.Rectangle;

public class WinnerAnimationController extends SceneObject
{
    public function WinnerAnimationController ()
    {
        var swf :SwfResourceLoader = BingoMain.resources.getResource("board") as SwfResourceLoader;
        var animClass :Class = swf.getClass("winner_symbol");

        _animView = new animClass();
    }

    public function set playerName (name :String) :void
    {
        var playerText :TextField = _animView["inst_player_name"];
        playerText.text = name;
    }

    override public function get displayObject () :DisplayObject
    {
        return _animView;
    }

    override protected function addedToDB () :void
    {
        BingoMain.control.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged, false, 0, true);

        this.handleSizeChanged();
    }

    override protected function removedFromDB () :void
    {
        BingoMain.control.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var loc :Point = this.properLocation;

        this.x = loc.x;
        this.y = loc.y;
    }

    protected function get properLocation () :Point
    {
        var loc :Point;

        if (BingoMain.control.isConnected()) {
            var stageSize :Rectangle = BingoMain.control.getStageSize(true);

            loc = (null != stageSize
                    ? new Point(stageSize.right + Constants.CARD_SCREEN_EDGE_OFFSET.x, stageSize.top + Constants.CARD_SCREEN_EDGE_OFFSET.y)
                    : new Point(0, 0));

        } else {
            loc = new Point(700 + Constants.CARD_SCREEN_EDGE_OFFSET.x, Constants.CARD_SCREEN_EDGE_OFFSET.y);
        }

        return loc;
    }

    protected var _animView :MovieClip;

}

}
