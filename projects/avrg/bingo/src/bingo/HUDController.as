package bingo {

import com.whirled.AVRGameControlEvent;

import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class HUDController
{
    public function HUDController ()
    {
        var hudClass :Class = BingoMain.resourcesDomain.getDefinition("HUD") as Class;
        _hud = new hudClass();

        BingoMain.sprite.addChild(_hud);

        // fix the text on the ball
        // @TODO - is TextFieldAutoSize accessible in the FAT? where?
        var ball :MovieClip = _hud["bingo_ball_inst"];
        var ballText :TextField = ball["text"];
        ballText.autoSize = TextFieldAutoSize.LEFT;

        // wire up buttons
        var quitButton :InteractiveObject = _hud["x_button"];
        quitButton.addEventListener(MouseEvent.CLICK, handleQuit, false, 0, true);

        var bingoButton :InteractiveObject = _hud["bingo_button"];
        bingoButton.addEventListener(MouseEvent.CLICK, handleBingo, false, 0, true);

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
    }

    public function destroy () :void
    {
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, updateScores);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_BALL, updateBall);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, updateBingoButton);
        BingoMain.model.removeEventListener(LocalStateChangedEvent.CARD_COMPLETED, updateBingoButton);

        BingoMain.control.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
    }

    public function update (percentTimeRemaining :Number) :void
    {
        var timer :MovieClip = _hud["inst_timer"];
        var totalFrames :int = timer.totalFrames;

        // 1.0 -> first frame; 0.0 -> last frame

        var curFrame :int = 1 + (totalFrames * (1.0 - percentTimeRemaining)); // frames are indexed from 1
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
            var stageSize :Rectangle = BingoMain.control.getStageSize(true);

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
        var scores :Array = BingoMain.model.curScores.scores;
        var scoreboardView :MovieClip = _hud["scoreboard"];

        for (var i :int = 0; i < NUM_SCOREBOARD_ROWS; ++i) {

            var nameField :TextField = scoreboardView["player_" + String(i + 1)];
            var scoreField :TextField = scoreboardView["score_" + String(i + 1)];

            var score :Score = (i < scores.length ? scores[i] : null);

            nameField.text = (score != null ? score.name : "");
            scoreField.text = (score != null ? String(score.score) : "");
        }
    }

    protected function updateBall (...ignored) :void
    {
        var ball :MovieClip = _hud["bingo_ball_inst"];
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

    protected var _hud :MovieClip;
    protected var _calledBingoThisRound :Boolean;

    protected static const NUM_SCOREBOARD_ROWS :int = 7;
    protected static const MAX_BALL_TEXT_WIDTH :Number = 62;
    protected static const SCREEN_EDGE_OFFSET :Point = new Point(-150, 230);

}

}
