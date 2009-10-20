package vampire.server.feeding
{
import com.threerings.util.HashMap;

import flash.events.Event;

public class FeedingHighScoreEvent extends Event
{
    public function FeedingHighScoreEvent(averageScore :Number, scores :HashMap)
    {
        super(HIGH_SCORE, false, false);
        _averageScore = averageScore;
        _scores = scores;
    }

    public function get averageScore () :Number
    {
        return _averageScore;
    }

    public function get scores () :HashMap
    {
        return _scores;
    }

    protected var _averageScore :Number;
    protected var _scores :HashMap;

    public static const HIGH_SCORE :String = "Feeding High Score";
}
}
