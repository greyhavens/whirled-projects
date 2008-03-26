package bingo {

import com.threerings.util.Log;
import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class HUDController extends SceneObject
{
    public function HUDController ()
    {
        var hudClass :Class = BingoMain.resourcesDomain.getDefinition("HUD") as Class;
        _hud = new hudClass();
    }

    override public function get displayObject () :DisplayObject
    {
        return _hud;
    }

    override protected function addedToDB () :void
    {
        // fix the text on the ball
        // @TODO - is TextFieldAutoSize accessible in the FAT? where?
        var ball :MovieClip = _hud["inst_bingo_ball"];
        var ballText :TextField = ball["text"];
        ballText.autoSize = TextFieldAutoSize.LEFT;

        // wire up buttons
        var quitButton :InteractiveObject = _hud["x_button"];
        quitButton.addEventListener(MouseEvent.CLICK, handleQuit, false, 0, true);

        var bingoButton :InteractiveObject = _hud["bingo_button"];
        bingoButton.addEventListener(MouseEvent.CLICK, handleBingo, false, 0, true);

        // @TODO - wire this up
        var helpButton :InteractiveObject = _hud["help_button"];
        helpButton.mouseEnabled = false;
        helpButton.visible = false;

        BingoMain.control.addEventListener(AVRGameControlEvent.PLAYER_ENTERED, updateScores, false, 0, true);
        BingoMain.control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, updateScores, false, 0, true);

        // listen for state events
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, updateScores, false, 0, true);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_BALL, updateBall, false, 0, true);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound, false, 0, true);
        BingoMain.model.addEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, updateBingoButton, false, 0, true);
        BingoMain.model.addEventListener(LocalStateChangedEvent.CARD_COMPLETED, updateBingoButton, false, 0, true);

        BingoMain.control.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged, false, 0, true);

        // set initial state
        this.updateScores();
        this.updateBall();
        this.updateBingoButton();
        this.handleSizeChanged();
        this.updateBallTimer();
    }

    override protected function removedFromDB () :void
    {
        log.info("removedFromDB()");

        BingoMain.control.removeEventListener(AVRGameControlEvent.PLAYER_ENTERED, updateScores);
        BingoMain.control.removeEventListener(AVRGameControlEvent.PLAYER_LEFT, updateScores);

        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, updateScores);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_BALL, updateBall);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, updateBingoButton);
        BingoMain.model.removeEventListener(LocalStateChangedEvent.CARD_COMPLETED, updateBingoButton);

        BingoMain.control.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
    }

    override protected function update (dt :Number) :void
    {
        this.updateBallTimer();
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
        var loc :Point;

        if (BingoMain.control.isConnected()) {
            var stageSize :Rectangle = BingoMain.control.getStageSize(false);

            loc = (null != stageSize
                    ? new Point(stageSize.right + SCREEN_EDGE_OFFSET.x, stageSize.top + SCREEN_EDGE_OFFSET.y)
                    : new Point(0, 0));

        } else {
            loc = new Point(700 + SCREEN_EDGE_OFFSET.x, SCREEN_EDGE_OFFSET.y);
        }

        return loc;
    }

    protected function handleQuit (...ignored) :void
    {
        BingoMain.quit();
    }

    protected function handleBingo (...ignored) :void
    {
        if (!_calledBingoThisRound && BingoMain.model.card.isComplete) {
            BingoMain.model.tryCallBingo();
            _calledBingoThisRound = true;
            this.updateBingoButton();
        }
    }

    protected function updateScores (...ignored) :void
    {
        var scores :Scoreboard = BingoMain.model.curScores;
        var scoreboardView :MovieClip = _hud["scoreboard"];

        var dateNow :Date = new Date();

        var namesAndScores :Array = BingoMain.model.getPlayerOids().map(
            function (playerId :int, ...ignored) :Score {
                var playerName :String = BingoMain.getPlayerName(playerId);
                var existingScore :Score = scores.getPlayerScore(playerName);

                return (null != existingScore ? existingScore : new Score(playerName, 0, dateNow));
            });

        namesAndScores.sort(Score.compare);

        for (var i :int = 0; i < NUM_SCOREBOARD_ROWS; ++i) {

            var score :Score = (i < namesAndScores.length ? namesAndScores[i] : null);

            var nameField :TextField = scoreboardView["player_" + String(i + 1)];
            var scoreField :TextField = scoreboardView["score_" + String(i + 1)];

            nameField.text = (null != score ? score.name : "");
            scoreField.text = (null != score && score.score > 0 ? String(score.score) : "");
        }
    }

    protected function updateBall (...ignored) :void
    {
        var ball :MovieClip = _hud["inst_bingo_ball"];
        var textField :TextField = ball["text"];

        ball.removeChild(textField);

        textField.scaleX = 1;
        textField.scaleY = 1;

        var ballString :String = BingoMain.model.curState.ballInPlay;
        textField.text = (null != ballString ? ballString : "");

        var scale :Number = MAX_BALL_TEXT_WIDTH / textField.textWidth;
        textField.scaleX = scale;
        textField.scaleY = scale;

        // re-center the text field
        textField.x = (ball.width * 0.5) - (textField.width * 0.5);
        textField.y = ((ball.height * 0.5) - (textField.height * 0.5)) - 2;

        ball.addChild(textField);
    }

    protected function updateBingoButton (...ignored) :void
    {
        var bingoButton :InteractiveObject = _hud["bingo_button"];
        var enabled :Boolean = (!_calledBingoThisRound && BingoMain.model.roundInPlay && null != BingoMain.model.card && BingoMain.model.card.isComplete);

        bingoButton.visible = enabled;
        bingoButton.mouseEnabled = enabled;
    }

    protected function handleNewRound (...ignored) :void
    {
        _calledBingoThisRound = false;
        this.updateBingoButton();
        this.updateBall();
    }

    protected function get gameMode () :GameMode
    {
        return this.db as GameMode;
    }

    protected var _hud :MovieClip;
    protected var _calledBingoThisRound :Boolean;

    protected static var log :Log = Log.getLog(HUDController);

    protected static const NUM_SCOREBOARD_ROWS :int = 7;
    protected static const MAX_BALL_TEXT_WIDTH :Number = 62;
    protected static const SCREEN_EDGE_OFFSET :Point = new Point(-150, 200);

}

}
