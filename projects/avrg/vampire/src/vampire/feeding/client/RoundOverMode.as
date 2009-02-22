package vampire.feeding.client {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.SelfDestructTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import mx.effects.easing.Cubic;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class RoundOverMode extends AppMode
{
    public function RoundOverMode (results :RoundResultsMsg)
    {
        _results = results;
    }

    override protected function setup () :void
    {
        super.setup();

        registerListener(ClientCtx.msgMgr, ClientMsgEvent.MSG_RECEIVED, onMsgReceived);

        var panelMovie :MovieClip = ClientCtx.instantiateMovieClip("blood", "popup_panel");
        panelMovie.x = 200;
        panelMovie.y = 200;
        _modeSprite.addChild(panelMovie);

        var startBloodMeter :MovieClip = panelMovie["target_starting"];
        startBloodMeter.gotoAndStop(startBloodMeter.totalFrames * _results.preyBloodStart);

        // animate the blood meter to show how much blood the prey lost
        var endBloodMeter :MovieClip = panelMovie["target_meter"];
        endBloodMeter.gotoAndStop(endBloodMeter.totalFrames);
        var bloodMeterAnimator :SimObject = new SimObject();
        var startFrame :int = endBloodMeter.totalFrames;
        var endFrame :int = endBloodMeter.totalFrames * _results.preyBloodEnd;
        bloodMeterAnimator.addTask(new SerialTask(
            new ShowFramesTask(
                endBloodMeter,
                startFrame,
                endFrame,
                Math.abs(endFrame - startFrame) / 45,
                mx.effects.easing.Cubic.easeOut),
            new SelfDestructTask()));
        addObject(bloodMeterAnimator);

        // Create the list of Objects that SimpleListController expects
        var totalScore :int;
        var listData :Array = [];
        _results.scores.forEach(
            function (playerId :int, score :int) :void {
                var obj :Object = {};
                obj["player_name"] = ClientCtx.getPlayerName(playerId);
                obj["player_score"] = score;
                listData.push(obj);
                totalScore += score;
            });

        addObject(new SimpleListController(
            listData,
            panelMovie,
            "player",
            [ "player_name", "player_score" ],
            "arrow_up",
            "arrow_down"));

        var totalScoreParent :MovieClip = panelMovie["total"];
        var tfTitle :TextField = totalScoreParent["player_name"];
        var tfScore :TextField = totalScoreParent["player_score"];
        tfTitle.text = "Total Score";
        tfScore.text = String(totalScore);

        _replayBtn = panelMovie["panel_button"];
        _feedingOverText = panelMovie["deadgame_text"];
        if (ClientCtx.noMoreFeeding) {
            noMoreFeeding();

        } else {
            _replayBtn.visible = true;
            _feedingOverText.visible = false;
            registerOneShotCallback(_replayBtn, MouseEvent.CLICK,
                function (...ignored) :void {
                     ClientCtx.roundMgr.reportReadyForNextRound();
                     _replayBtn.visible = false;
                });
        }

        var quitBtn :SimpleButton = panelMovie["button_close"];
        registerOneShotCallback(quitBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.quit(true);
            });

        // hide the timer
        _replayTimer = panelMovie["replay_timer"];
        _replayTimer.visible = false;
    }

    protected function onMsgReceived (e :ClientMsgEvent) :void
    {
        if (e.msg is RoundStartingSoonMsg && !_replayTimer.visible) {
            // animate the timer to indicate that the round will start soon
            _replayTimer.visible = true;
            var timerAnimObj :SimObject = new SimObject();
            timerAnimObj.addTask(new ShowFramesTask(
                _replayTimer,
                0,
                ShowFramesTask.LAST_FRAME,
                Constants.WAIT_FOR_PLAYERS_TIMEOUT));
            addObject(timerAnimObj);

        } else if (e.msg is NoMoreFeedingMsg) {
            noMoreFeeding();
        }
    }

    protected function noMoreFeeding () :void
    {
        _replayTimer.visible = false;
        _replayBtn.visible = false;
        _feedingOverText.visible = true;
        _feedingOverText.text = (ClientCtx.isPrey ? "You are alone." : "Your prey has escaped!");
    }

    protected var _results :RoundResultsMsg;
    protected var _replayTimer :MovieClip;
    protected var _replayBtn :SimpleButton;
    protected var _feedingOverText :TextField;

    protected static var log :Log = Log.getLog(RoundOverMode);
}

}
