package bingo {

import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

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
        var screenBounds :Rectangle = BingoMain.getScreenBounds();

        return new Point(
            screenBounds.right + Constants.CARD_SCREEN_EDGE_OFFSET.x,
            screenBounds.top + Constants.CARD_SCREEN_EDGE_OFFSET.y);
    }

    protected var _animView :MovieClip;

}

}
