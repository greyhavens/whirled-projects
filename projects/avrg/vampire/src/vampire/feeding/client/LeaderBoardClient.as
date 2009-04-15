package vampire.feeding.client
{
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.text.TextField;

import vampire.server.LeaderBoardServer;

public class LeaderBoardClient extends SceneObject
{
    public function LeaderBoardClient(leaderBoardPanel :MovieClip)
    {
        _leaderBoardPanel = leaderBoardPanel;
        registerListener(ClientCtx.gameCtrl.game.props, PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChangedEvent);

        updateScoresFromProps();
    }

    protected function handlePropertyChangedEvent (e: PropertyChangedEvent) :void
    {
        trace("handlePropertyChangedEvent e=" + e);
        var ii :int;
        var scores :Array;
        if (e.name == LeaderBoardServer.GLOBAL_PROP_SCORES_DAILY) {

            setTextFromPropScores(e.newValue as Array,
                                  "today_0",
                                  LeaderBoardServer.NUMBER_HIGH_SCORES_DAILY);
        }
        else if (e.name == LeaderBoardServer.GLOBAL_PROP_SCORES_MONTHLY) {

            setTextFromPropScores(e.newValue as Array,
                                  "monthly_0",
                                  LeaderBoardServer.NUMBER_HIGH_SCORES_MONTHLY);
        }
    }

    protected function updateScoresFromProps (...ignored) :void
    {
        trace("updateScoresFromProps, daily="
            + ClientCtx.gameCtrl.game.props.get(LeaderBoardServer.GLOBAL_PROP_SCORES_DAILY)
            + ", monthly="
            + ClientCtx.gameCtrl.game.props.get(LeaderBoardServer.GLOBAL_PROP_SCORES_MONTHLY));

        setTextFromPropScores(
            ClientCtx.gameCtrl.game.props.get(LeaderBoardServer.GLOBAL_PROP_SCORES_DAILY) as Array,
            "today_0",
            LeaderBoardServer.NUMBER_HIGH_SCORES_DAILY);

        setTextFromPropScores(
            ClientCtx.gameCtrl.game.props.get(LeaderBoardServer.GLOBAL_PROP_SCORES_MONTHLY) as Array,
            "monthly_0",
            LeaderBoardServer.NUMBER_HIGH_SCORES_MONTHLY);

    }

    protected function setTextFromPropScores (scores :Array, textFieldName :String,
        textFieldCount :int) :void
    {
        var ii :int;
        //Set text null
        for (ii = 0; ii < textFieldCount; ++ii) {
            TextField(_leaderBoardPanel[textFieldName + (ii+1) ]["player_name"]).text = "";
            TextField(_leaderBoardPanel[textFieldName + (ii+1) ]["player_score"]).text = "";
        }

        if (scores != null) {
            for (ii = 0; ii < textFieldCount && ii < scores.length; ++ii) {

                var score :Array = scores[ii] as Array;
                if (score != null && score.length >= 2) {
                    var scorePanel :MovieClip =
                        _leaderBoardPanel[textFieldName + (ii+1) ] as MovieClip;
                    if (scorePanel != null) {
                        TextField(scorePanel["player_name"]).text = "" + score[1];
                        TextField(scorePanel["player_score"]).text = score[0];
                    }
                }
            }
        }

    }

    override public function get displayObject () :DisplayObject
    {
        return _leaderBoardPanel;
    }

    protected var _leaderBoardPanel :MovieClip;
}
}