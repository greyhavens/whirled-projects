package bingo {

import com.threerings.util.Log;
import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

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
        var swf :SwfResourceLoader = BingoMain.resources.getResource("ui") as SwfResourceLoader;
        var hudClass :Class = swf.getClass("HUD");
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
        this.ballTextField.autoSize = TextFieldAutoSize.LEFT;

        // wire up buttons
        var quitButton :InteractiveObject = _hud["x_button"];
        quitButton.addEventListener(MouseEvent.CLICK, handleQuit, false, 0, true);

        var bingoButton :InteractiveObject = _hud["bingo_button"];
        bingoButton.addEventListener(MouseEvent.CLICK, handleBingo, false, 0, true);

        var helpButton :InteractiveObject = _hud["help_button"];
        helpButton.visible = false;
        helpButton.mouseEnabled = false;
        helpButton.addEventListener(MouseEvent.CLICK, handleHelp, false, 0, true);

        BingoMain.control.addEventListener(AVRGameControlEvent.PLAYER_ENTERED, updateScores);
        BingoMain.control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, updateScores);

        // listen for state events
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, updateScores);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_BALL, updateBall);
        BingoMain.model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChanged);
        BingoMain.model.addEventListener(LocalStateChangedEvent.CARD_COMPLETED, updateBingoButton);

        BingoMain.control.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);

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
        BingoMain.model.removeEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChanged);
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
        var screenBounds :Rectangle = BingoMain.getScreenBounds();

        return new Point(
            screenBounds.right + Constants.HUD_SCREEN_EDGE_OFFSET.x,
            screenBounds.top + Constants.HUD_SCREEN_EDGE_OFFSET.y);
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

    protected function handleHelp (...ignored) :void
    {
        // @TODO - this probably can't be a new mode - we need the game to keep running while it's up
        //MainLoop.instance.pushMode(new HelpMode());
    }

    protected function updateScores (...ignored) :void
    {
        var scores :ScoreTable = BingoMain.model.curScores;
        var scoreboardView :MovieClip = _hud["scoreboard"];

        var dateNow :Date = new Date();

        var namesAndScores :Array = BingoMain.model.getPlayerOids().map(
            function (playerId :int, ...ignored) :Score {
                var existingScore :Score = scores.getScore(playerId);

                return (null != existingScore ? existingScore : new Score(playerId, 0, dateNow));
            });

        namesAndScores.sort(Score.compareScores);

        for (var i :int = 0; i < NUM_SCOREBOARD_ROWS; ++i) {

            var score :Score = (i < namesAndScores.length ? namesAndScores[i] : null);

            var nameField :TextField = scoreboardView["player_" + String(i + 1)];
            var scoreField :TextField = scoreboardView["score_" + String(i + 1)];

            nameField.text = (null != score ? BingoMain.getPlayerName(score.playerId) : "");
            scoreField.text = (null != score && score.score > 0 ? String(score.score) : "");
        }
    }

    protected function updateBall (...ignored) :void
    {
        var textField :TextField = this.ballTextField;

        textField.scaleX = 1;
        textField.scaleY = 1;

        var ballString :String = BingoMain.model.curState.ballInPlay;
        textField.text = (null != ballString ? ballString : "");

        var scale :Number = MAX_BALL_TEXT_WIDTH / textField.textWidth;
        textField.scaleX = scale;
        textField.scaleY = scale;

        textField.y = BALL_TEXT_Y_CENTER - (textField.height * 0.5);

        // play two animations in sequence: animate out the old ball, animate in the new one

        // destroy any current animations
        /*this.db.destroyObjectNamed(BALL_ANIMATE_OUT_OBJ_NAME);
        this.db.destroyObjectNamed(BALL_ANIMATE_IN_OBJ_NAME);

        var swf :SwfResourceLoader = BingoMain.resources.getResource("ui") as SwfResourceLoader;
        var animateOutClass :Class = swf.getClass("bingoball_animate_out");
        var animateInClass :Class = swf.getClass("bingoball_animate_in");

        var animateOut :MovieClip = new animateOutClass();
        var animateIn :MovieClip = new animateInClass();

        animateIn.visible = false;

        var animateOutObj :SimpleSceneObject = new SimpleSceneObject(animateOut, BALL_ANIMATE_OUT_OBJ_NAME);
        var animateInObj :SimpleSceneObject = new SimpleSceneObject(animateIn, BALL_ANIMATE_IN_OBJ_NAME);

        var animateOutTask :SerialTask = new SerialTask();
        animateOutTask.addTask(new TimedTask(1.2));
        animateOutTask.addTask(new SelfDestructTask());
        animateOutObj.addTask(animateOutTask);

        var animateInTask :SerialTask = new SerialTask();
        animateInTask.addTask(new TimedTask(1.2));
        animateInTask.addTask(new VisibleTask(true));
        animateInTask.addTask(new TimedTask(1.2));
        animateInTask.addTask(new SelfDestructTask());
        animateInObj.addTask(animateInTask);

        this.db.addObject(animateOutObj, _hud);
        this.db.addObject(animateInObj, _hud);*/
    }

    protected function updateBingoButton (...ignored) :void
    {
        var bingoButton :InteractiveObject = _hud["bingo_button"];
        var enabled :Boolean = (!_calledBingoThisRound && BingoMain.model.roundInPlay && null != BingoMain.model.card && BingoMain.model.card.isComplete);

        bingoButton.visible = enabled;
        bingoButton.mouseEnabled = enabled;
    }

    protected function handleGameStateChanged (...ignored) :void
    {
        switch (BingoMain.model.curState.gameState) {

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

    protected function get ballTextField () :TextField
    {
        return _hud["inst_text"];
    }

    protected var _hud :MovieClip;
    protected var _calledBingoThisRound :Boolean;

    protected static var log :Log = Log.getLog(HUDController);

    protected static const NUM_SCOREBOARD_ROWS :int = 7;
    protected static const MAX_BALL_TEXT_WIDTH :Number = 62;
    protected static const BALL_TEXT_Y_CENTER :Number = -138;

    protected static const BALL_ANIMATE_OUT_OBJ_NAME :String = "animateOut";
    protected static const BALL_ANIMATE_IN_OBJ_NAME :String = "animateIn";

}

}
