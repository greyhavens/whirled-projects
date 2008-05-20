package bingo {

import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

public class WinnerAnimationController extends SceneObject
{
    public static const NAME :String = "WinnerAnimationController";

    public function WinnerAnimationController (playerName :String)
    {
        _animationParent = new Sprite();
        _winnerAnim = SwfResource.instantiateMovieClip("board", "bingo_winner_animation");
        _animationParent.addChild(_winnerAnim);

        // ugh - traverse the MovieClip's crazy display hierarchy
        // to fill in the player's name
        var winAnimation :MovieClip = _winnerAnim["inst_win_animation"];
        var playerTextFieldParent :MovieClip = winAnimation["textbox_symbol"];
        var playerTextField :TextField = playerTextFieldParent["inst_textbox"];

        playerTextField.text = playerName;

        // Listen for the "complete" event. We'll start a countdown timer afterwards.
        _winnerAnim.addEventListener(Event.COMPLETE, winnerAnimComplete, false, 0, true);
    }

    protected function winnerAnimComplete (...ignored) :void
    {
        _animationParent.removeChild(_winnerAnim);
        _winnerAnim.removeEventListener(Event.COMPLETE, winnerAnimComplete);
        _winnerAnim = null;

        // and show the countdown timer
        var animView :MovieClip = SwfResource.instantiateMovieClip("board", "board_time_left");
        _animationParent.addChild(animView);

        _countdownText = animView["inst_time_left"];
        _showingCountdown = true;
        _countdownTime = Constants.NEW_ROUND_DELAY_S;

        this.updateCountdownText();
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_showingCountdown) {
            _countdownTime -= dt;
            this.updateCountdownText();

            if (_countdownTime <= 0) {
                this.destroySelf();
            }
        }
    }

    protected function updateCountdownText () :void
    {
        var minutes :Number = Math.floor(_countdownTime / 60);
        var seconds :Number = Math.floor(_countdownTime % 60);

        var countdownString :String = (minutes > 0 ? minutes.toString() : "0") + ":";

        if (seconds <= 9) {
            countdownString += "0" + seconds.toString();
        } else {
            countdownString += seconds.toString();
        }

        _countdownText.text = countdownString;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override public function get displayObject () :DisplayObject
    {
        return _animationParent;
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

    protected var _winnerAnim :MovieClip;

    protected var _animationParent :Sprite;

    protected var _countdownTime :Number;
    protected var _showingCountdown :Boolean;
    protected var _countdownText :TextField;

}

}
