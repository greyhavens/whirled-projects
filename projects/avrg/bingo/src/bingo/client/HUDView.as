package bingo.client {

import bingo.*;

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class HUDView extends SceneObject
{
    public static const NAME :String = "HUDController";

    public function HUDView ()
    {
        _hud = SwfResource.instantiateMovieClip("ui", "HUD");

        // fix the text on the ball
        // @TODO - is TextFieldAutoSize accessible in the FAT? where?
        _bingoBall = _hud["inst_bingoball_animate"];
        var ballTextParent :MovieClip = _bingoBall["inst_text_symbol"];
        _ballText = ballTextParent["inst_text"];
        _ballText.text = "";

        _ballText.autoSize = TextFieldAutoSize.LEFT;

        // wire up buttons
        var quitButton :InteractiveObject = _hud["x_button"];
        registerEventListener(quitButton, MouseEvent.CLICK, handleQuit);

        var bingoButton :InteractiveObject = _hud["bingo_button"];
        registerEventListener(bingoButton, MouseEvent.CLICK, handleBingo);

        var helpButton :InteractiveObject = _hud["help_button"];
        registerEventListener(helpButton, MouseEvent.CLICK, handleHelp);

        // listen for state events
        registerEventListener(ClientContext.model, SharedStateChangedEvent.NEW_SCORES,
            updateScores);
        registerEventListener(ClientContext.model, SharedStateChangedEvent.NEW_BALL,
            updateBall);
        registerEventListener(ClientContext.model, SharedStateChangedEvent.GAME_STATE_CHANGED,
            handleGameStateChanged);
        registerEventListener(ClientContext.model, LocalStateChangedEvent.CARD_COMPLETED,
            updateBingoButton);

        registerEventListener(ClientContext.gameCtrl.local, AVRGameControlEvent.SIZE_CHANGED,
            handleSizeChanged);

        registerEventListener(ClientContext.gameCtrl.room, AVRGameRoomEvent.PLAYER_ENTERED,
            updateScores);
        registerEventListener(ClientContext.gameCtrl.room, AVRGameRoomEvent.PLAYER_LEFT,
            updateScores);
    }

    override public function get displayObject () :DisplayObject
    {
        return _hud;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override protected function addedToDB () :void
    {
        // set initial state
        updateScores();
        updateBall();
        updateBingoButton();
        handleSizeChanged();
        updateBallTimer();
    }

    override protected function update (dt :Number) :void
    {
        updateBallTimer();
    }

    protected function updateBallTimer () :void
    {
        var timer :MovieClip = _hud["inst_timer"];
        var totalFrames :int = timer.totalFrames;

        // 1.0 -> first frame; 0.0 -> last frame

        var curFrame :int = 1 + (totalFrames * (1.0 - this.gameMode.percentTimeTillNextBall));
        curFrame = Math.min(curFrame, totalFrames);
        curFrame = Math.max(curFrame, 1);

        timer.gotoAndStop(curFrame);
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var loc :Point = this.properLocation;

        _hud.x = loc.x;
        _hud.y = loc.y;
    }

    protected function get properLocation () :Point
    {
        var screenBounds :Rectangle = ClientContext.getScreenBounds();

        return new Point(
            screenBounds.right + Constants.HUD_SCREEN_EDGE_OFFSET.x,
            screenBounds.top + Constants.HUD_SCREEN_EDGE_OFFSET.y);
    }

    protected function handleQuit (...ignored) :void
    {
        ClientContext.quit();
    }

    protected function handleBingo (...ignored) :void
    {
        if (!_calledBingoThisRound && ClientContext.model.card.isComplete) {
            ClientContext.model.callBingo();
            _calledBingoThisRound = true;
            this.updateBingoButton();
        }
    }

    protected function handleHelp (...ignored) :void
    {
        this.gameMode.showHelpScreen();
    }

    protected function updateScores (...ignored) :void
    {
        var scores :ScoreTable = ClientContext.model.curScores;
        var scoreboardView :MovieClip = _hud["scoreboard"];

        var dateNow :Date = new Date();

        var namesAndScores :Array = ClientContext.model.getPlayerOids().map(
            function (playerId :int, ...ignored) :Score {
                var existingScore :Score = scores.getScore(playerId);
                return (null != existingScore ? existingScore : new Score(playerId, 0, dateNow));
            });

        namesAndScores.sort(compareScores);

        for (var i :int = 0; i < NUM_SCOREBOARD_ROWS; ++i) {

            var score :Score = (i < namesAndScores.length ? namesAndScores[i] : null);

            var nameField :TextField = scoreboardView["player_" + String(i + 1)];
            var scoreField :TextField = scoreboardView["score_" + String(i + 1)];

            nameField.text = (null != score ? ClientContext.getPlayerName(score.playerId) : "");
            scoreField.text = (null != score && score.score > 0 ? String(score.score) : "");
        }
    }

    protected function updateBall (...ignored) :void
    {
        registerOneShotCallback(_bingoBall, Event.COMPLETE, showNewBallText);
        _bingoBall.gotoAndPlay(0);
    }

    protected function showNewBallText (...ignored) :void
    {
        var newText :String = ClientContext.model.curState.ballInPlay;
        setBallText(_ballText, newText);
    }

    protected static function setBallText (textField :TextField, text :String) :void
    {
        // attempt to properly scale and position text on the bingo ball,
        // or on one of the bingo ball animations

        textField.scaleX = 1;
        textField.scaleY = 1;

        textField.text = text;

        var scale :Number = MAX_BALL_TEXT_WIDTH / textField.textWidth;
        textField.scaleX = scale;
        textField.scaleY = scale;

        textField.y = BALL_TEXT_Y_CENTER - (textField.height * 0.5);
    }

    protected function updateBingoButton (...ignored) :void
    {
        var bingoButton :InteractiveObject = _hud["bingo_button"];
        var enabled :Boolean = (
            !_calledBingoThisRound &&
            ClientContext.model.roundInPlay &&
            ClientContext.model.card != null &&
            ClientContext.model.card.isComplete);

        bingoButton.visible = enabled;
        bingoButton.mouseEnabled = enabled;
    }

    protected function handleGameStateChanged (...ignored) :void
    {
        switch (ClientContext.model.curState.gameState) {

        case SharedState.STATE_PLAYING:
            _calledBingoThisRound = false;
            this.updateBingoButton();
            this.updateBall();
            break;

        case SharedState.STATE_WEHAVEAWINNER:
            this.updateBingoButton();
            break;
        }
    }

    protected function get gameMode () :GameMode
    {
        return this.db as GameMode;
    }

    protected static function compareScores (a :Score, b :Score) :int
    {
        // compare scores. higher scores come before lower
        if (a.score > b.score) {
            return -1;
        } else if (a.score < b.score) {
            return 1;
        }

        // compare dates. newer dates come before older
        var aTime :Number = a.date.time;
        var bTime :Number = b.date.time;

        if (aTime > bTime) {
            return -1;
        } else if (aTime < bTime) {
            return 1;
        }

        // compare names. A comes before Z
        var aName :String = ClientContext.getPlayerName(a.playerId);
        var bName :String = ClientContext.getPlayerName(b.playerId);

        return aName.localeCompare(bName);
    }

    protected var _hud :MovieClip;
    protected var _calledBingoThisRound :Boolean;

    protected var _bingoBall :MovieClip;
    protected var _ballText :TextField;

    protected static var log :Log = Log.getLog(HUDView);

    protected static const NUM_SCOREBOARD_ROWS :int = 7;
    protected static const MAX_BALL_TEXT_WIDTH :Number = 62;
    protected static const BALL_TEXT_Y_CENTER :Number = 42;

}

}
