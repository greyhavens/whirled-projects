package bingo.client {

import bingo.*;

import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

public class WinnerAnimationView extends SceneObject
{
    public static const NAME :String = "WinnerAnimationController";

    public function WinnerAnimationView (playerName :String)
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

        ClientContext.gameMode.destroyObjectNamed(NEXT_ROUND_TIMER_NAME);
        ClientContext.gameMode.addObject(new SimpleTimer(
            Constants.NEW_ROUND_DELAY_S, null, false, NEXT_ROUND_TIMER_NAME));

        // Listen for the "complete" event. We'll show the countdown timer afterwards.
        registerOneShotCallback(_winnerAnim, Event.COMPLETE, winnerAnimComplete);

        registerEventListener(ClientContext.gameCtrl.local, AVRGameControlEvent.SIZE_CHANGED,
            handleSizeChanged);
    }

    override protected function addedToDB () :void
    {
        handleSizeChanged();
    }

    protected function winnerAnimComplete (...ignored) :void
    {
        _animationParent.removeChild(_winnerAnim);
        _winnerAnim = null;

        // and show the countdown timer
        var animView :MovieClip = SwfResource.instantiateMovieClip("board", "board_time_left");
        _animationParent.addChild(animView);

        _countdownText = animView["inst_time_left"];
        updateCountdownText(SimpleTimer.getTimeLeft(NEXT_ROUND_TIMER_NAME));
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_countdownText != null) {
            var timeLeft :Number = SimpleTimer.getTimeLeft(NEXT_ROUND_TIMER_NAME);
            this.updateCountdownText(timeLeft);
            if (timeLeft <= 0) {
                ClientContext.gameMode.destroyObjectNamed(NEXT_ROUND_TIMER_NAME);
                this.destroySelf();
            }
        }
    }

    protected function updateCountdownText (timeLeft :Number) :void
    {
        var minutes :Number = Math.floor(timeLeft / 60);
        var seconds :Number = Math.floor(timeLeft % 60);

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

    protected function handleSizeChanged (...ignored) :void
    {
        var loc :Point = this.properLocation;

        this.x = loc.x;
        this.y = loc.y;
    }

    protected function get properLocation () :Point
    {
        var screenBounds :Rectangle = ClientContext.getScreenBounds();

        return new Point(
            screenBounds.right + Constants.CARD_SCREEN_EDGE_OFFSET.x,
            screenBounds.top + Constants.CARD_SCREEN_EDGE_OFFSET.y);
    }

    protected var _winnerAnim :MovieClip;
    protected var _animationParent :Sprite;
    protected var _countdownText :TextField;

    protected static const NEXT_ROUND_TIMER_NAME :String = "NextRoundTimer";

}

}
