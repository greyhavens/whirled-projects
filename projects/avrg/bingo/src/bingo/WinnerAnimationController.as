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
    public function WinnerAnimationController (playerName :String)
    {
        var swf :SwfResourceLoader = BingoMain.resources.getResource("board") as SwfResourceLoader;
        var animClass :Class = swf.getClass("bingo_winner_animation");

        _animView = new animClass();

        // ugh - traverse the MovieClip's crazy display hierarchy
        // to fill in the player's name
        /*var winAnimation :MovieClip = _animView["inst_win_animation"];
        var playerTextFieldParent :MovieClip = winAnimation["textbox_symbol"];
        var playerTextField :TextField = playerTextField["inst_textbox"];

        playerTextField.text = playerName;*/
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
