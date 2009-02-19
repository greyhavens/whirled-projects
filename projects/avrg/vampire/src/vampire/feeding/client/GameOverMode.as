package vampire.feeding.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.SelfDestructTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import mx.effects.easing.Cubic;

import vampire.feeding.net.RoundResultsMsg;

public class GameOverMode extends AppMode
{
    public function GameOverMode (results :RoundResultsMsg)
    {
        _results = results;
    }

    override protected function setup () :void
    {
        super.setup();

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

        // wire up buttons
        var replayBtn :SimpleButton = panelMovie["panel_button"];
        registerOneShotCallback(replayBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                // TODO
            });

        var quitBtn :SimpleButton = panelMovie["button_close"];
        registerOneShotCallback(quitBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                // TODO
            });
    }

    protected var _results :RoundResultsMsg
}

}
